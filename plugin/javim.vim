" plugin/javim.vim
if exists('g:loaded_javim')
  finish
endif
let g:loaded_javim = 1

command! -nargs=+ JavimRun call s_run_javim(<f-args>)

function! s_run_javim(...) abort
  if a:0 == 0
    echoerr 'Usage: JavimRun <class_name> [args...]'
    return
  endif
  let l:class_name = a:1
  let l:args = a:0 > 1 ? a:000[1:] : []

  " Create a clean, isolated VM state
  let l:vm_state = {
  \   'classes': {},
  \   'heap': {},
  \   'next_object_id': 1,
  \   'static_fields': {},
  \   'classpath': ['.'],
  \ }

  " Map arguments to String references inside the JVM
  let l:arg_refs = []
  for l:a in l:args
    call add(l:arg_refs, javim#interpreter#new_string(l:a, l:vm_state))
  endfor

  " Mock JVM array for arguments
  let l:array_ref = javim#interpreter#new_object('[Ljava/lang/String;', l:vm_state)
  let l:vm_state.heap[l:array_ref].__fields__['_elements'] = l:arg_refs

  try
    call javim#interpreter#execute_method(l:class_name, 'main([Ljava/lang/String;)V', [l:array_ref], l:vm_state)
  catch
    echoerr 'JVM Runtime Error: ' . v:exception
  endtry
endfunction
