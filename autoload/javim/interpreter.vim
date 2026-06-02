let s:save_cpo = &cpo
set cpo&vim

" autoload/javim/interpreter.vim

function! javim#interpreter#load_class(class_name, vm_state) abort
  let l:normalized = substitute(a:class_name, '\.', '/', 'g')
  if has_key(a:vm_state.classes, l:normalized)
    return a:vm_state.classes[l:normalized]
  endif

  " 0. Handle dynamically created array types (classes starting with '[')
  if l:normalized[0] ==# '['
    let l:class_dict = {
    \   'this_class': l:normalized,
    \   'super_class': 'java/lang/Object',
    \   'access_flags': 0x0001,
    \   'fields': [],
    \   'methods': {},
    \ }
    let a:vm_state.classes[l:normalized] = l:class_dict
    return l:class_dict
  endif

  " 1. Search in native runtime mocks under autoload/javim/rt/
  let l:rt_func = 'javim#rt#' . substitute(l:normalized, '/', '#', 'g') . '#get'
  try
    let l:class_dict = call(l:rt_func, [])
    let a:vm_state.classes[l:normalized] = l:class_dict
    call s:init_static_fields(l:normalized, l:class_dict, a:vm_state)
    return l:class_dict
  catch /^Vim\%((\a\+)\)\=:E117/
    " Native mock function not found, proceed to classpath
  endtry

  " 2. Search in physical classpath
  for l:dir in a:vm_state.classpath
    let l:path = l:dir . '/' . l:normalized . '.class'
    if filereadable(l:path)
      let l:class_dict = javim#classfile#parse(l:path)
      let a:vm_state.classes[l:normalized] = l:class_dict
      call s:init_static_fields(l:normalized, l:class_dict, a:vm_state)
      return l:class_dict
    endif
  endfor

  throw 'ClassNotFoundException: ' . a:class_name
endfunction

function! s:init_static_fields(class_name, class_dict, vm_state) abort
  " Initialize static fields with default values
  for l:f in get(a:class_dict, 'fields', [])
    if and(l:f.access_flags, 0x0008) " ACC_STATIC
      let l:key = a:class_name . '.' . l:f.name
      let a:vm_state.static_fields[l:key] = s:default_value(l:f.descriptor)
    endif
  endfor

  " Run <clinit>()V if it exists
  if has_key(a:class_dict.methods, '<clinit>()V')
    " Execute in isolation (without recursive loop trigger)
    call javim#interpreter#execute_method(a:class_name, '<clinit>()V', [], a:vm_state)
  endif
endfunction

function! s:default_value(desc) abort
  if a:desc ==# 'Z'
    return 0 " Boolean false
  elseif a:desc ==# 'I' || a:desc ==# 'B' || a:desc ==# 'C' || a:desc ==# 'S'
    return 0 " Integer default
  elseif a:desc ==# 'J'
    return [0, 0] " Long default representation
  elseif a:desc ==# 'F' || a:desc ==# 'D'
    return 0
  else
    return {'null': 1} " Object null reference
  endif
endfunction

function! javim#interpreter#new_object(class_name, vm_state) abort
  let l:id = a:vm_state.next_object_id
  let a:vm_state.next_object_id += 1

  " Accumulate all non-static fields across superclass chain
  let l:fields = {}
  let l:curr = a:class_name
  while l:curr !=# '' && l:curr !=# 'java/lang/Object'
    " Note: java/lang/Object does not have fields, so we can stop or load safely
    let l:c_dict = javim#interpreter#load_class(l:curr, a:vm_state)
    for l:f in get(l:c_dict, 'fields', [])
      if !and(l:f.access_flags, 0x0008) " Not static
        let l:fields[l:f.name] = s:default_value(l:f.descriptor)
      endif
    endfor
    let l:curr = get(l:c_dict, 'super_class', '')
  endwhile

  let l:obj = {
  \   '__id__': l:id,
  \   '__class__': a:class_name,
  \   '__fields__': l:fields,
  \ }
  let a:vm_state.heap[l:id] = l:obj
  return l:id
endfunction

function! javim#interpreter#new_string(vim_str, vm_state) abort
  let l:ref = javim#interpreter#new_object('java/lang/String', a:vm_state)
  let a:vm_state.heap[l:ref].__fields__['value'] = a:vim_str
  return l:ref
endfunction

function! javim#interpreter#to_vim_string(ref, vm_state) abort
  if type(a:ref) == type({}) && has_key(a:ref, 'null')
    return 'null'
  endif
  if !has_key(a:vm_state.heap, a:ref)
    return 'null'
  endif
  let l:obj = a:vm_state.heap[a:ref]
  return get(l:obj.__fields__, 'value', '')
endfunction

function! javim#interpreter#execute_method(class_name, method_sig, args, vm_state) abort
  let l:c_dict = javim#interpreter#load_class(a:class_name, a:vm_state)
  let l:method = s:resolve_method(a:class_name, a:method_sig, a:vm_state)

  if get(l:method, 'native', 0)
    " Execute direct native Vim Script code hook
    let l:frame = {
    \   'local_variables': a:args,
    \   'operand_stack': [],
    \ }
    return l:method.exec(l:frame, a:vm_state)
  endif

  " Execute standard Java bytecode instruction method
  let l:frame = {
  \   'local_variables': copy(a:args),
  \   'operand_stack': [],
  \   'pc': 0,
  \   'method_code': l:method.code,
  \   'constant_pool': l:c_dict.constant_pool,
  \   'method_sig': a:method_sig,
  \   'class_name': a:class_name,
  \ }

  " Pad local variable array up to max_locals limit
  while len(l:frame.local_variables) < l:method.max_locals
    call add(l:frame.local_variables, 0)
  endwhile

  return javim#interpreter#run_loop(l:frame, a:vm_state)
endfunction

function! s:resolve_method(class_name, method_sig, vm_state) abort
  let l:curr = a:class_name
  while l:curr !=# ''
    let l:c_dict = javim#interpreter#load_class(l:curr, a:vm_state)
    if has_key(l:c_dict.methods, a:method_sig)
      return l:c_dict.methods[a:method_sig]
    endif
    let l:curr = get(l:c_dict, 'super_class', '')
  endwhile
  throw 'NoSuchMethodError: ' . a:class_name . '.' . a:method_sig
endfunction

function! javim#interpreter#run_loop(frame, vm_state) abort
  let l:code = a:frame.method_code
  let l:code_len = len(l:code)

  while a:frame.pc < l:code_len
    let l:opcode = l:code[a:frame.pc]
    let a:frame.pc += 1

    call javim#instructions#exec(l:opcode, a:frame, a:vm_state)
    if has_key(a:frame, 'returned')
      return a:frame.return_value
    endif
  endwhile

  " Fallback return
  return v:null
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
