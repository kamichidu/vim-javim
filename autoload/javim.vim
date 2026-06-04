" autoload/javim.vim

let s:save_cpo = &cpo
set cpo&vim

function! javim#run(...) abort
  if a:0 == 0
    echoerr 'Usage: JavimRun [-cp <classpath>] <class_name> [args...]'
    return
  endif

  let l:classpath = ['.']
  let l:class_idx = 1

  if a:1 ==# '-cp' || a:1 ==# '-classpath'
    if a:0 < 3
      echoerr 'Usage: JavimRun [-cp <classpath>] <class_name> [args...]'
      return
    endif
    let l:cp_str = a:2
    let l:sep = (has('win32') || has('win64')) ? ';' : ':'
    let l:classpath = split(l:cp_str, l:sep)
    let l:class_idx = 3
  endif

  let l:class_name = a:000[l:class_idx - 1]
  let l:args = a:0 > l:class_idx ? a:000[l:class_idx :] : []

  let l:expanded_classpath = javim#interpreter#expand_classpath(l:classpath)

  " Create a clean, isolated VM state
  let l:vm_state = {
  \   'classes': {},
  \   'heap': {},
  \   'next_object_id': 1,
  \   'static_fields': {},
  \   'classpath': l:expanded_classpath,
  \ }

  " Map arguments to String references inside the JVM
  let l:arg_refs = []
  for l:a in l:args
    call add(l:arg_refs, javim#interpreter#new_string(l:a, l:vm_state))
  endfor

  " Create JVM array for arguments
  let l:array_ref = javim#interpreter#new_object('[Ljava/lang/String;', l:vm_state)
  let l:vm_state.heap[l:array_ref].__fields__['_elements'] = l:arg_refs

  try
    call javim#interpreter#execute_method(l:class_name, 'main([Ljava/lang/String;)V', [l:array_ref], l:vm_state)
  catch
    echoerr 'JVM Runtime Error: ' . v:exception
  endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
