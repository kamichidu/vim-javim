" test/suite/classfile_test.vim

let s:save_cpo = &cpo
set cpo&vim

function! s:test_classfile_parse() abort
  let l:res = javim#classfile#parse('test/classes/HelloWorld.class')

  call assert_equal(0xCAFEBABE, l:res.magic)
  call assert_equal('test/classes/HelloWorld', l:res.this_class)
  call assert_equal('java/lang/Object', l:res.super_class)

  " Check that the main method is parsed correctly
  if !has_key(l:res.methods, 'main([Ljava/lang/String;)V')
    call add(v:errors, 'main method not found in methods keys')
    return
  endif

  let l:main = l:res.methods['main([Ljava/lang/String;)V']
  call assert_notequal(0, len(l:main.code))

  " Check that the constructor <init>()V is parsed
  if !has_key(l:res.methods, '<init>()V')
    call add(v:errors, '<init> method not found in methods keys')
    return
  endif
endfunction

call s:test_classfile_parse()


let &cpo = s:save_cpo
unlet s:save_cpo
