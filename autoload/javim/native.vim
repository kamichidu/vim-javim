" autoload/javim/native.vim

let s:save_cpo = &cpo
set cpo&vim

" Native shared helpers can be added here if needed in the future.
" Currently, standard class native methods are self-contained and executed
" directly via their respective class definition dictionaries.
function! javim#native#info() abort
  return 'javim native bridge'
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
