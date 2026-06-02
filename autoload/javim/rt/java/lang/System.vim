" autoload/javim/rt/java/lang/System.vim

function! javim#rt#java#lang#System#get() abort
  return {
  \   'this_class': 'java/lang/System',
  \   'super_class': 'java/lang/Object',
  \   'access_flags': 0x0001,
  \   'fields': [
  \     {'access_flags': 0x0019, 'name': 'out', 'descriptor': 'Ljava/io/PrintStream;'},
  \   ],
  \   'methods': {
  \     '<clinit>()V': {
  \       'native': 1,
  \       'exec': function('s_clinit'),
  \     }
  \   }
  \ }
endfunction

function! s_clinit(frame, vm_state) abort
  " Allocate a new PrintStream instance and assign it to System.out static field
  let l:ref = javim#interpreter#new_object('java/io/PrintStream', a:vm_state)
  let a:vm_state.static_fields['java/lang/System.out'] = l:ref
  return v:null
endfunction
