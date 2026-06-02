" autoload/javim/rt/java/lang/StringBuilder.vim

let s:save_cpo = &cpo
set cpo&vim

function! javim#rt#java#lang#StringBuilder#get() abort
  return {
  \   'this_class': 'java/lang/StringBuilder',
  \   'super_class': 'java/lang/Object',
  \   'access_flags': 0x0001,
  \   'fields': [],
  \   'methods': {
  \     '<init>()V': {
  \       'native': 1,
  \       'exec': function('s:init'),
  \     },
  \     'append(Ljava/lang/String;)Ljava/lang/StringBuilder;': {
  \       'native': 1,
  \       'exec': function('s:append_string'),
  \     },
  \     'append(I)Ljava/lang/StringBuilder;': {
  \       'native': 1,
  \       'exec': function('s:append_int'),
  \     },
  \     'toString()Ljava/lang/String;': {
  \       'native': 1,
  \       'exec': function('s:toString'),
  \     }
  \   }
  \ }
endfunction

function! s:init(frame, vm_state) abort
  let l:this = a:frame.local_variables[0]
  let a:vm_state.heap[l:this].__fields__['_buffer'] = ''
  return v:null
endfunction

function! s:append_string(frame, vm_state) abort
  let l:this = a:frame.local_variables[0]
  let l:str_ref = a:frame.local_variables[1]
  let l:str = javim#interpreter#to_vim_string(l:str_ref, a:vm_state)
  let a:vm_state.heap[l:this].__fields__['_buffer'] .= l:str
  return l:this
endfunction

function! s:append_int(frame, vm_state) abort
  let l:this = a:frame.local_variables[0]
  let l:val = a:frame.local_variables[1]
  let a:vm_state.heap[l:this].__fields__['_buffer'] .= string(l:val)
  return l:this
endfunction

function! s:toString(frame, vm_state) abort
  let l:this = a:frame.local_variables[0]
  let l:buf = get(a:vm_state.heap[l:this].__fields__, '_buffer', '')
  return javim#interpreter#new_string(l:buf, a:vm_state)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
