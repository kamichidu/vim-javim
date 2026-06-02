" plugin/javim.vim
if exists('g:loaded_javim')
  finish
endif
let g:loaded_javim = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=+ JavimRun call s:run_javim(<f-args>)

function! s:run_javim(...) abort
  call call('javim#run', a:000)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
