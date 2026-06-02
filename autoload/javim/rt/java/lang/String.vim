" autoload/javim/rt/java/lang/String.vim

let s:save_cpo = &cpo
set cpo&vim

function! javim#rt#java#lang#String#get() abort
  return {
  \   'this_class': 'java/lang/String',
  \   'super_class': 'java/lang/Object',
  \   'access_flags': 0x0001,
  \   'fields': [],
  \   'methods': {
  \     '<init>()V': {
  \       'native': 1,
  \       'exec': function('s:init'),
  \     },
  \     'length()I': {
  \       'native': 1,
  \       'exec': function('s:length'),
  \     }
  \   }
  \ }
endfunction

function! s:init(frame, vm_state) abort
  let l:this = a:frame.local_variables[0]
  if !has_key(a:vm_state.heap[l:this].__fields__, 'value')
    let a:vm_state.heap[l:this].__fields__['value'] = ''
  endif
  return v:null
endfunction

function! s:length(frame, vm_state) abort
  let l:this = a:frame.local_variables[0]
  let l:val = get(a:vm_state.heap[l:this].__fields__, 'value', '')
  return len(l:val)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
