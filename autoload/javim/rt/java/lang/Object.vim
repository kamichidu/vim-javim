let s:save_cpo = &cpo
set cpo&vim

" autoload/javim/rt/java/lang/Object.vim

function! javim#rt#java#lang#Object#get() abort
  return {
  \   'this_class': 'java/lang/Object',
  \   'super_class': '',
  \   'access_flags': 0x0001,
  \   'fields': [],
  \   'methods': {
  \     '<init>()V': {
  \       'native': 1,
  \       'exec': function('s:init'),
  \     },
  \     'toString()Ljava/lang/String;': {
  \       'native': 1,
  \       'exec': function('s:toString'),
  \     },
  \     'equals(Ljava/lang/Object;)Z': {
  \       'native': 1,
  \       'exec': function('s:equals'),
  \     }
  \   }
  \ }
endfunction

function! s:init(frame, vm_state) abort
  return v:null
endfunction

function! s:toString(frame, vm_state) abort
  let l:this = a:frame.local_variables[0]
  let l:cls = a:vm_state.heap[l:this].__class__
  let l:str = l:cls . '@' . string(l:this)
  return javim#interpreter#new_string(l:str, a:vm_state)
endfunction

function! s:equals(frame, vm_state) abort
  let l:this = a:frame.local_variables[0]
  let l:other = a:frame.local_variables[1]
  return l:this == l:other ? 1 : 0
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
