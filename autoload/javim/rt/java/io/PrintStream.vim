let s:save_cpo = &cpo
set cpo&vim

" autoload/javim/rt/java/io/PrintStream.vim

function! javim#rt#java#io#PrintStream#get() abort
  return {
  \   'this_class': 'java/io/PrintStream',
  \   'super_class': 'java/lang/Object',
  \   'access_flags': 0x0001,
  \   'fields': [],
  \   'methods': {
  \     '<init>()V': {
  \       'native': 1,
  \       'exec': function('s:init'),
  \     },
  \     'println(Ljava/lang/String;)V': {
  \       'native': 1,
  \       'exec': function('s:println_string'),
  \     },
  \     'println(I)V': {
  \       'native': 1,
  \       'exec': function('s:println_int'),
  \     }
  \   }
  \ }
endfunction

function! s:init(frame, vm_state) abort
  return v:null
endfunction

function! s:println_string(frame, vm_state) abort
  let l:str_ref = a:frame.local_variables[1]
  let l:str = javim#interpreter#to_vim_string(l:str_ref, a:vm_state)

  " Capture stdout inside the VM state for automated testing assertions
  if !has_key(a:vm_state, 'stdout')
    let a:vm_state.stdout = []
  endif
  call add(a:vm_state.stdout, l:str)

  echo l:str
  return v:null
endfunction

function! s:println_int(frame, vm_state) abort
  let l:val = a:frame.local_variables[1]

  if !has_key(a:vm_state, 'stdout')
    let a:vm_state.stdout = []
  endif
  call add(a:vm_state.stdout, string(l:val))

  echo l:val
  return v:null
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
