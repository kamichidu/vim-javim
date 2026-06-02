" test/run_tests.vim

let s:save_cpo = &cpo
set cpo&vim
set verbose=1
set rtp+=.

let s:test_files = [
\   'test/suite/classfile_test.vim',
\   'test/suite/interpreter_test.vim',
\ ]

let g:test_errors = []

for s:file in s:test_files
  echo 'Running ' . s:file . '...'
  try
    source `=s:file`
  catch
    call add(g:test_errors, 'Error while sourcing ' . s:file . ': ' . v:exception . ' at ' . v:throwpoint)
  endtry
endfor

if len(v:errors) > 0 || len(g:test_errors) > 0
  echo '=== TEST FAILURES ==='
  for err in v:errors
    echo err
  endfor
  for err in g:test_errors
    echo err
  endfor
  cquit!
else
  echo 'All tests passed successfully!'
  q!
endif


let &cpo = s:save_cpo
unlet s:save_cpo
