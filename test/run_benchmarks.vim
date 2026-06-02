let s:save_cpo = &cpo
set cpo&vim

" test/run_benchmarks.vim
set verbose=1
set rtp+=.

" 1. Gather Metadata
let s:timestamp = strftime('%Y-%m-%d %H:%M:%S')
let s:vim_version = split(execute('version'), "\n")[0]
let s:os = has('win32') || has('win64') ? 'Windows' : (has('mac') || has('macunix') ? 'macOS' : 'Linux/Unix')

" Initialize Results List
let s:results = []
call add(s:results, '============================================================')
call add(s:results, 'javim Benchmark Results (Regression Detection)')
call add(s:results, '============================================================')
call add(s:results, 'Timestamp:   ' . s:timestamp)
call add(s:results, 'Vim Version: ' . s:vim_version)
call add(s:results, 'OS:          ' . s:os)
call add(s:results, '============================================================')

" Helper function to load a class with localized &verbose = 0.
" This prevents Vim from printing "not found in 'runtimepath'" warning logs
" on stderr when searching for native runtime stubs (which is normal and caught internally).
" It avoids using global silent! which could swallow genuine errors.
function! s:load_class_silently(class_name, vm_state) abort
  let l:save_verbose = &verbose
  set verbose=0
  try
    let l:res = javim#interpreter#load_class(a:class_name, a:vm_state)
  finally
    let &verbose = l:save_verbose
  endtry
  return l:res
endfunction

" Define unique temporary directory for caching
let s:temp_base = tempname()
let g:javim_cache_dir = s:temp_base . '_javim_benchmark_cache'

" --- [Measurement 1: Classfile Parse] ---
let s:class_file = 'test/classes/Fibonacci.class'
let s:iter_parse = 100
let s:start = reltime()
for s:i in range(s:iter_parse - 1)
  let s:res = javim#classfile#parse(s:class_file)
endfor
let s:elapsed_parse = reltimefloat(reltime(s:start))
call add(s:results, printf('1. Classfile Parse:                     %.6fs (%d iterations, avg: %.6fs)', s:elapsed_parse, s:iter_parse, s:elapsed_parse / s:iter_parse))

" --- [Measurement 2: Simple Loop Program Execution] ---
let s:vm_state = {
\   'classes': {},
\   'heap': {},
\   'next_object_id': 1,
\   'static_fields': {},
\   'classpath': ['.'],
\   'stdout': [],
\ }
" Load safely without warnings and without swallowing real syntax/runtime errors
call s:load_class_silently('test.classes.LoopBenchmark', s:vm_state)

" Run 3 times to get a stable average time, executing run(I)I directly to prevent printing standard output
let s:iter_loop = 3
let s:start = reltime()
for s:i in range(s:iter_loop - 1)
  let s:res_val = javim#interpreter#execute_method('test.classes.LoopBenchmark', 'run(I)I', [10000], s:vm_state)
  if s:res_val != 49995000
    throw 'Benchmark error: LoopBenchmark returned incorrect value: ' . string(s:res_val)
  endif
endfor
let s:elapsed_loop = reltimefloat(reltime(s:start))
call add(s:results, printf('2. Simple Loop Program Execution:       %.6fs (%d iterations, avg: %.6fs)', s:elapsed_loop, s:iter_loop, s:elapsed_loop / s:iter_loop))

" --- [Measurement 3: Recursive Method Invocation] ---
let s:vm_state_rec = {
\   'classes': {},
\   'heap': {},
\   'next_object_id': 1,
\   'static_fields': {},
\   'classpath': ['.'],
\   'stdout': [],
\ }
" Load safely without warnings and without swallowing real syntax/runtime errors
call s:load_class_silently('test.classes.Fibonacci', s:vm_state_rec)

let s:iter_rec = 50
let s:start = reltime()
for s:i in range(s:iter_rec - 1)
  call javim#interpreter#execute_method('test.classes.Fibonacci', 'fib(I)I', [12], s:vm_state_rec)
endfor
let s:elapsed_rec = reltimefloat(reltime(s:start))
call add(s:results, printf('3. Recursive Method Invocation:         %.6fs (%d iterations, avg: %.6fs)', s:elapsed_rec, s:iter_rec, s:elapsed_rec / s:iter_rec))

" --- [Measurement 4: Classpath Directory Load] ---
let s:iter_cp = 1000
let s:start = reltime()
for s:i in range(s:iter_cp - 1)
  let s:expanded = javim#interpreter#expand_classpath(['test/classes'])
endfor
let s:elapsed_cp = reltimefloat(reltime(s:start))
call add(s:results, printf('4. Classpath Directory Load:            %.6fs (%d iterations, avg: %.6fs)', s:elapsed_cp, s:iter_cp, s:elapsed_cp / s:iter_cp))

" --- [JAR Feature Availability Check] ---
if executable('unzip')
  " --- [Measurement 5: JAR Classpath Cold Extraction] ---
  if isdirectory(g:javim_cache_dir)
    call delete(g:javim_cache_dir, 'rf')
  endif

  let s:start = reltime()
  let s:expanded = javim#interpreter#expand_classpath(['test/classes/test_hello.jar'])
  let s:elapsed_jar_cold = reltimefloat(reltime(s:start))
  call add(s:results, printf('5. JAR Classpath Cold Extraction:       %.6fs (1 iteration)', s:elapsed_jar_cold))

  " --- [Measurement 6: JAR Classpath Cache Hit] ---
  let s:iter_hit = 100
  let s:start = reltime()
  for s:i in range(s:iter_hit - 1)
    let s:expanded = javim#interpreter#expand_classpath(['test/classes/test_hello.jar'])
  endfor
  let s:elapsed_jar_hit = reltimefloat(reltime(s:start))
  call add(s:results, printf('6. JAR Classpath Cache Hit:             %.6fs (%d iterations, avg: %.6fs)', s:elapsed_jar_hit, s:iter_hit, s:elapsed_jar_hit / s:iter_hit))
else
  call add(s:results, '5. JAR Classpath Cold Extraction:       SKIP (unzip not found)')
  call add(s:results, '6. JAR Classpath Cache Hit:             SKIP (unzip not found)')
endif

call add(s:results, '============================================================')

" Clean up the unique temporary benchmark cache directory
if isdirectory(g:javim_cache_dir)
  call delete(g:javim_cache_dir, 'rf')
endif

" Print results to standard output
for s:line in s:results
  echo s:line
endfor

q!

let &cpo = s:save_cpo
unlet s:save_cpo
