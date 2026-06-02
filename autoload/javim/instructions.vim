let s:save_cpo = &cpo
set cpo&vim

" autoload/javim/instructions.vim

function! s:read_u1(frame) abort
  let l:val = a:frame.method_code[a:frame.pc]
  let a:frame.pc += 1
  return l:val
endfunction

function! s:read_u2(frame) abort
  let l:val = (a:frame.method_code[a:frame.pc] * 256) + a:frame.method_code[a:frame.pc + 1]
  let a:frame.pc += 2
  return l:val
endfunction

function! s:read_s1(frame) abort
  let l:val = s:read_u1(a:frame)
  return l:val >= 128 ? l:val - 256 : l:val
endfunction

function! s:read_s2(frame) abort
  let l:val = s:read_u2(a:frame)
  return l:val >= 32768 ? l:val - 65536 : l:val
endfunction

function! s:resolve_methodref(cp, idx) abort
  let l:ref = a:cp[a:idx]
  let l:class_name = a:cp[a:cp[l:ref.class_index].name_index].val
  let l:nt = a:cp[l:ref.name_and_type_index]
  let l:name = a:cp[l:nt.name_index].val
  let l:desc = a:cp[l:nt.descriptor_index].val
  return {
  \   'class_name': l:class_name,
  \   'name': l:name,
  \   'descriptor': l:desc,
  \   'sig': l:name . l:desc
  \ }
endfunction

function! s:resolve_fieldref(cp, idx) abort
  let l:ref = a:cp[a:idx]
  let l:class_name = a:cp[a:cp[l:ref.class_index].name_index].val
  let l:nt = a:cp[l:ref.name_and_type_index]
  let l:name = a:cp[l:nt.name_index].val
  let l:desc = a:cp[l:nt.descriptor_index].val
  return {
  \   'class_name': l:class_name,
  \   'name': l:name,
  \   'descriptor': l:desc
  \ }
endfunction

function! javim#instructions#parse_descriptor(desc) abort
  let l:args_part = matchstr(a:desc, '(\zs.*\ze)')
  let l:args = []
  let l:i = 0
  let l:len = len(l:args_part)
  while l:i < l:len
    let l:char = l:args_part[l:i]
    if l:char ==# 'B' || l:char ==# 'C' || l:char ==# 'D' || l:char ==# 'F' || l:char ==# 'I' || l:char ==# 'J' || l:char ==# 'S' || l:char ==# 'Z'
      call add(l:args, l:char)
      let l:i += 1
    elseif l:char ==# 'L'
      let l:end = stridx(l:args_part, ';', l:i)
      let l:ref_type = l:args_part[l:i + 1 : l:end - 1]
      call add(l:args, 'L' . l:ref_type)
      let l:i = l:end + 1
    elseif l:char ==# '['
      let l:i += 1
      while l:args_part[l:i] ==# '['
        let l:i += 1
      endwhile
      if l:args_part[l:i] ==# 'L'
        let l:end = stridx(l:args_part, ';', l:i)
        let l:i = l:end + 1
      else
        let l:i += 1
      endif
      call add(l:args, '[')
    else
      let l:i += 1
    endif
  endwhile
  return l:args
endfunction

function! javim#instructions#exec(opcode, frame, vm_state) abort
  if a:opcode == 0x00 " nop
    " Do nothing

  elseif a:opcode == 0x01 " aconst_null
    call add(a:frame.operand_stack, {'null': 1})

  elseif a:opcode == 0x02 " iconst_m1
    call add(a:frame.operand_stack, -1)

  elseif a:opcode >= 0x03 && a:opcode <= 0x08 " iconst_0 to iconst_5
    call add(a:frame.operand_stack, a:opcode - 0x03)

  elseif a:opcode == 0x10 " bipush
    let l:val = s:read_s1(a:frame)
    call add(a:frame.operand_stack, l:val)

  elseif a:opcode == 0x11 " sipush
    let l:val = s:read_s2(a:frame)
    call add(a:frame.operand_stack, l:val)

  elseif a:opcode == 0x12 " ldc
    let l:idx = s:read_u1(a:frame)
    let l:cp_entry = a:frame.constant_pool[l:idx]
    if l:cp_entry.tag == 1 " UTF8
      let l:ref = javim#interpreter#new_string(l:cp_entry.val, a:vm_state)
      call add(a:frame.operand_stack, l:ref)
    elseif l:cp_entry.tag == 8 " String Index
      let l:utf8_val = a:frame.constant_pool[l:cp_entry.string_index].val
      let l:ref = javim#interpreter#new_string(l:utf8_val, a:vm_state)
      call add(a:frame.operand_stack, l:ref)
    elseif l:cp_entry.tag == 3 " Integer
      call add(a:frame.operand_stack, l:cp_entry.val)
    else
      throw 'Unsupported ldc constant tag: ' . l:cp_entry.tag
    endif

  elseif a:opcode == 0x15 " iload
    let l:idx = s:read_u1(a:frame)
    call add(a:frame.operand_stack, a:frame.local_variables[l:idx])

  elseif a:opcode == 0x19 " aload
    let l:idx = s:read_u1(a:frame)
    call add(a:frame.operand_stack, a:frame.local_variables[l:idx])

  elseif a:opcode >= 0x1a && a:opcode <= 0x1d " iload_0 to iload_3
    let l:idx = a:opcode - 0x1a
    call add(a:frame.operand_stack, a:frame.local_variables[l:idx])

  elseif a:opcode >= 0x2a && a:opcode <= 0x2d " aload_0 to aload_3
    let l:idx = a:opcode - 0x2a
    call add(a:frame.operand_stack, a:frame.local_variables[l:idx])

  elseif a:opcode == 0x36 " istore
    let l:idx = s:read_u1(a:frame)
    let a:frame.local_variables[l:idx] = remove(a:frame.operand_stack, -1)

  elseif a:opcode == 0x3a " astore
    let l:idx = s:read_u1(a:frame)
    let a:frame.local_variables[l:idx] = remove(a:frame.operand_stack, -1)

  elseif a:opcode >= 0x3b && a:opcode <= 0x3e " istore_0 to istore_3
    let l:idx = a:opcode - 0x3b
    let a:frame.local_variables[l:idx] = remove(a:frame.operand_stack, -1)

  elseif a:opcode >= 0x4b && a:opcode <= 0x4e " astore_0 to astore_3
    let l:idx = a:opcode - 0x4b
    let a:frame.local_variables[l:idx] = remove(a:frame.operand_stack, -1)

  elseif a:opcode == 0x57 " pop
    call remove(a:frame.operand_stack, -1)

  elseif a:opcode == 0x59 " dup
    let l:val = a:frame.operand_stack[-1]
    call add(a:frame.operand_stack, l:val)

  elseif a:opcode == 0x60 " iadd
    let l:b = remove(a:frame.operand_stack, -1)
    let l:a = remove(a:frame.operand_stack, -1)
    call add(a:frame.operand_stack, l:a + l:b)

  elseif a:opcode == 0x64 " isub
    let l:b = remove(a:frame.operand_stack, -1)
    let l:a = remove(a:frame.operand_stack, -1)
    call add(a:frame.operand_stack, l:a - l:b)

  elseif a:opcode == 0x68 " imul
    let l:b = remove(a:frame.operand_stack, -1)
    let l:a = remove(a:frame.operand_stack, -1)
    call add(a:frame.operand_stack, l:a * l:b)

  elseif a:opcode == 0x6c " idiv
    let l:b = remove(a:frame.operand_stack, -1)
    let l:a = remove(a:frame.operand_stack, -1)
    call add(a:frame.operand_stack, l:a / l:b)

  elseif a:opcode == 0x84 " iinc
    let l:idx = s:read_u1(a:frame)
    let l:const = s:read_s1(a:frame)
    let a:frame.local_variables[l:idx] += l:const

  elseif a:opcode >= 0x99 && a:opcode <= 0x9e " ifeq, ifne, iflt, ifge, ifgt, ifle
    let l:offset = s:read_s2(a:frame)
    let l:val = remove(a:frame.operand_stack, -1)
    let l:cond = 0
    if a:opcode == 0x99 | let l:cond = (l:val == 0)
    elseif a:opcode == 0x9a | let l:cond = (l:val != 0)
    elseif a:opcode == 0x9b | let l:cond = (l:val < 0)
    elseif a:opcode == 0x9c | let l:cond = (l:val >= 0)
    elseif a:opcode == 0x9d | let l:cond = (l:val > 0)
    elseif a:opcode == 0x9e | let l:cond = (l:val <= 0)
    endif
    if l:cond
      let a:frame.pc = a:frame.pc - 3 + l:offset
    endif

  elseif a:opcode >= 0x9f && a:opcode <= 0xa4 " if_icmpeq to if_icmple
    let l:offset = s:read_s2(a:frame)
    let l:b = remove(a:frame.operand_stack, -1)
    let l:a = remove(a:frame.operand_stack, -1)
    let l:cond = 0
    if a:opcode == 0x9f | let l:cond = (l:a == l:b)
    elseif a:opcode == 0xa0 | let l:cond = (l:a != l:b)
    elseif a:opcode == 0xa1 | let l:cond = (l:a < l:b)
    elseif a:opcode == 0xa2 | let l:cond = (l:a >= l:b)
    elseif a:opcode == 0xa3 | let l:cond = (l:a > l:b)
    elseif a:opcode == 0xa4 | let l:cond = (l:a <= l:b)
    endif
    if l:cond
      let a:frame.pc = a:frame.pc - 3 + l:offset
    endif

  elseif a:opcode == 0xa7 " goto
    let l:offset = s:read_s2(a:frame)
    let a:frame.pc = a:frame.pc - 3 + l:offset

  elseif a:opcode == 0xac " ireturn
    let a:frame.returned = 1
    let a:frame.return_value = remove(a:frame.operand_stack, -1)

  elseif a:opcode == 0xb0 " areturn
    let a:frame.returned = 1
    let a:frame.return_value = remove(a:frame.operand_stack, -1)

  elseif a:opcode == 0xb1 " return
    let a:frame.returned = 1
    let a:frame.return_value = v:null

  elseif a:opcode == 0xb2 " getstatic
    let l:idx = s:read_u2(a:frame)
    let l:fieldref = s:resolve_fieldref(a:frame.constant_pool, l:idx)
    call javim#interpreter#load_class(l:fieldref.class_name, a:vm_state)
    let l:key = l:fieldref.class_name . '.' . l:fieldref.name
    let l:val = get(a:vm_state.static_fields, l:key, 0)
    call add(a:frame.operand_stack, l:val)

  elseif a:opcode == 0xb3 " putstatic
    let l:idx = s:read_u2(a:frame)
    let l:fieldref = s:resolve_fieldref(a:frame.constant_pool, l:idx)
    call javim#interpreter#load_class(l:fieldref.class_name, a:vm_state)
    let l:val = remove(a:frame.operand_stack, -1)
    let l:key = l:fieldref.class_name . '.' . l:fieldref.name
    let a:vm_state.static_fields[l:key] = l:val

  elseif a:opcode == 0xb4 " getfield
    let l:idx = s:read_u2(a:frame)
    let l:fieldref = s:resolve_fieldref(a:frame.constant_pool, l:idx)
    let l:ref = remove(a:frame.operand_stack, -1)
    if type(l:ref) == type({}) && has_key(l:ref, 'null')
      throw 'NullPointerException'
    endif
    let l:obj = a:vm_state.heap[l:ref]
    let l:val = get(l:obj.__fields__, l:fieldref.name, 0)
    call add(a:frame.operand_stack, l:val)

  elseif a:opcode == 0xb5 " putfield
    let l:idx = s:read_u2(a:frame)
    let l:fieldref = s:resolve_fieldref(a:frame.constant_pool, l:idx)
    let l:val = remove(a:frame.operand_stack, -1)
    let l:ref = remove(a:frame.operand_stack, -1)
    if type(l:ref) == type({}) && has_key(l:ref, 'null')
      throw 'NullPointerException'
    endif
    let l:obj = a:vm_state.heap[l:ref]
    let l:obj.__fields__[l:fieldref.name] = l:val

  elseif a:opcode == 0xb6 || a:opcode == 0xb7 || a:opcode == 0xb8 " invokevirtual, invokespecial, invokestatic
    let l:idx = s:read_u2(a:frame)
    let l:mref = s:resolve_methodref(a:frame.constant_pool, l:idx)

    let l:args_types = javim#instructions#parse_descriptor(l:mref.descriptor)
    let l:num_args = len(l:args_types)
    let l:args_vals = []
    let l:i = 0
    while l:i < l:num_args
      call insert(l:args_vals, remove(a:frame.operand_stack, -1), 0)
      let l:i += 1
    endwhile

    if a:opcode == 0xb8 " invokestatic
      let l:res = javim#interpreter#execute_method(l:mref.class_name, l:mref.sig, l:args_vals, a:vm_state)
      if l:mref.descriptor !~# ')V$'
        call add(a:frame.operand_stack, l:res)
      endif
    else " invokevirtual or invokespecial
      let l:this_ref = remove(a:frame.operand_stack, -1)
      if type(l:this_ref) == type({}) && has_key(l:this_ref, 'null')
        throw 'NullPointerException'
      endif
      call insert(l:args_vals, l:this_ref, 0)

      let l:target_class = l:mref.class_name
      if a:opcode == 0xb6 " invokevirtual (dynamic dispatch)
        let l:target_class = a:vm_state.heap[l:this_ref].__class__
      endif

      let l:res = javim#interpreter#execute_method(l:target_class, l:mref.sig, l:args_vals, a:vm_state)
      if l:mref.descriptor !~# ')V$'
        call add(a:frame.operand_stack, l:res)
      endif
    endif

  elseif a:opcode == 0xbb " new
    let l:idx = s:read_u2(a:frame)
    let l:class_entry = a:frame.constant_pool[l:idx]
    let l:class_name = a:frame.constant_pool[l:class_entry.name_index].val
    call javim#interpreter#load_class(l:class_name, a:vm_state)
    let l:ref = javim#interpreter#new_object(l:class_name, a:vm_state)
    call add(a:frame.operand_stack, l:ref)

  else
    throw 'Unsupported opcode: ' . printf('0x%02x', a:opcode)
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
