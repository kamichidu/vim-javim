" test/suite/interpreter_test.vim

let s:save_cpo = &cpo
set cpo&vim

function! s:test_hello_world() abort
  let l:vm_state = {
  \   'classes': {},
  \   'heap': {},
  \   'next_object_id': 1,
  \   'static_fields': {},
  \   'classpath': ['.'],
  \   'stdout': [],
  \ }

  let l:array_ref = javim#interpreter#new_object('[Ljava/lang/String;', l:vm_state)
  let l:vm_state.heap[l:array_ref].__fields__['_elements'] = []

  call javim#interpreter#execute_method('test.classes.HelloWorld', 'main([Ljava/lang/String;)V', [l:array_ref], l:vm_state)

  call assert_equal(['Hello, World!'], l:vm_state.stdout)
endfunction

function! s:test_math_and_loop() abort
  let l:vm_state = {
  \   'classes': {},
  \   'heap': {},
  \   'next_object_id': 1,
  \   'static_fields': {},
  \   'classpath': ['.'],
  \   'stdout': [],
  \ }

  let l:array_ref = javim#interpreter#new_object('[Ljava/lang/String;', l:vm_state)
  let l:vm_state.heap[l:array_ref].__fields__['_elements'] = []

  call javim#interpreter#execute_method('test.classes.MathTest', 'main([Ljava/lang/String;)V', [l:array_ref], l:vm_state)

  call assert_equal(['5', '15'], l:vm_state.stdout)
endfunction

function! s:test_fibonacci() abort
  let l:vm_state = {
  \   'classes': {},
  \   'heap': {},
  \   'next_object_id': 1,
  \   'static_fields': {},
  \   'classpath': ['.'],
  \   'stdout': [],
  \ }

  let l:array_ref = javim#interpreter#new_object('[Ljava/lang/String;', l:vm_state)
  let l:vm_state.heap[l:array_ref].__fields__['_elements'] = []

  call javim#interpreter#execute_method('test.classes.Fibonacci', 'main([Ljava/lang/String;)V', [l:array_ref], l:vm_state)

  call assert_equal(['55'], l:vm_state.stdout)
endfunction

function! s:test_custom_classpath() abort
  let l:vm_state = {
  \   'classes': {},
  \   'heap': {},
  \   'next_object_id': 1,
  \   'static_fields': {},
  \   'classpath': ['./test'],
  \   'stdout': [],
  \ }

  let l:class_dict = javim#interpreter#load_class('classes.HelloWorld', l:vm_state)
  call assert_equal('test/classes/HelloWorld', l:class_dict.this_class)
endfunction

function! s:test_jar_classpath() abort
  let l:expanded = javim#interpreter#expand_classpath(['test/classes/test_hello.jar'])
  call assert_equal(1, len(l:expanded))
  call assert_match('\.cache/javim/', l:expanded[0])
  call assert_true(isdirectory(l:expanded[0]))

  let l:vm_state = {
  \   'classes': {},
  \   'heap': {},
  \   'next_object_id': 1,
  \   'static_fields': {},
  \   'classpath': l:expanded,
  \   'stdout': [],
  \ }

  let l:class_dict = javim#interpreter#load_class('test.classes.HelloWorld', l:vm_state)
  call assert_equal('test/classes/HelloWorld', l:class_dict.this_class)
endfunction

function! s:test_wildcard_classpath() abort
  let l:expanded = javim#interpreter#expand_classpath(['test/classes/*.jar'])
  call assert_equal(1, len(l:expanded))
  call assert_match('\.cache/javim/', l:expanded[0])
  call assert_true(isdirectory(l:expanded[0]))

  let l:vm_state = {
  \   'classes': {},
  \   'heap': {},
  \   'next_object_id': 1,
  \   'static_fields': {},
  \   'classpath': l:expanded,
  \   'stdout': [],
  \ }

  let l:class_dict = javim#interpreter#load_class('test.classes.HelloWorld', l:vm_state)
  call assert_equal('test/classes/HelloWorld', l:class_dict.this_class)
endfunction

function! s:test_cache_dir_configuration() abort
  let g:javim_cache_dir = expand('~/.cache/javim_test_custom')
  let l:expanded = javim#interpreter#expand_classpath(['test/classes/test_hello.jar'])
  call assert_equal(1, len(l:expanded))
  call assert_match('javim_test_custom', l:expanded[0])
  call assert_true(isdirectory(l:expanded[0]))
  
  if isdirectory(g:javim_cache_dir)
    call delete(g:javim_cache_dir, 'rf')
  endif
  unlet g:javim_cache_dir
endfunction

function! s:test_javim_run() abort
  " Test standard javim#run call with classpath
  try
    call javim#run('-cp', '.', 'test.classes.HelloWorld')
  catch
    call assert_false(1, 'javim#run failed: ' . v:exception)
  endtry

  " Test javim#run with no classpath (defaults to '.')
  try
    call javim#run('test.classes.HelloWorld')
  catch
    call assert_false(1, 'javim#run without -cp failed: ' . v:exception)
  endtry
endfunction

call s:test_hello_world()
call s:test_math_and_loop()
call s:test_fibonacci()
call s:test_custom_classpath()
call s:test_jar_classpath()
call s:test_wildcard_classpath()
call s:test_cache_dir_configuration()
call s:test_javim_run()


let &cpo = s:save_cpo
unlet s:save_cpo
