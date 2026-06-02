let s:save_cpo = &cpo
set cpo&vim

" test/suite/interpreter_test.vim

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

call s:test_hello_world()
call s:test_math_and_loop()
call s:test_fibonacci()
call s:test_custom_classpath()


let &cpo = s:save_cpo
unlet s:save_cpo
