let s:save_cpo = &cpo
set cpo&vim

" autoload/javim/classfile.vim

function! javim#classfile#parse(filepath) abort
  if !filereadable(a:filepath)
    throw 'Classfile not found: ' . a:filepath
  endif
  let l:blob = readfile(a:filepath, 'B')
  let l:r = s:new_reader(l:blob)

  let l:magic = l:r.u4()
  if l:magic != 0xCAFEBABE
    throw 'Invalid classfile magic: ' . printf('%x', l:magic)
  endif

  let l:minor = l:r.u2()
  let l:major = l:r.u2()

  let l:cp_count = l:r.u2()
  let l:cp = s:parse_cp(l:r, l:cp_count)

  let l:flags = l:r.u2()
  let l:this_class_idx = l:r.u2()
  let l:super_class_idx = l:r.u2()

  let l:this_class = l:cp[l:cp[l:this_class_idx].name_index].val
  let l:super_class = l:super_class_idx == 0 ? '' : l:cp[l:cp[l:super_class_idx].name_index].val

  " Interfaces
  let l:interfaces_count = l:r.u2()
  let l:interfaces = []
  let l:i = 0
  while l:i < l:interfaces_count
    let l:iface_idx = l:r.u2()
    call add(l:interfaces, l:cp[l:cp[l:iface_idx].name_index].val)
    let l:i += 1
  endwhile

  " Fields
  let l:fields_count = l:r.u2()
  let l:fields = []
  let l:i = 0
  while l:i < l:fields_count
    let l:f_flags = l:r.u2()
    let l:f_name_idx = l:r.u2()
    let l:f_desc_idx = l:r.u2()
    let l:f_attr_count = l:r.u2()
    " Skip attributes for fields for now
    let l:j = 0
    while l:j < l:f_attr_count
      let l:sub_name_idx = l:r.u2()
      let l:sub_len = l:r.u4()
      let l:unused_bytes = l:r.bytes(l:sub_len)
      let l:j += 1
    endwhile
    call add(l:fields, {
    \   'access_flags': l:f_flags,
    \   'name': l:cp[l:f_name_idx].val,
    \   'descriptor': l:cp[l:f_desc_idx].val,
    \ })
    let l:i += 1
  endwhile

  " Methods
  let l:methods_count = l:r.u2()
  let l:methods = s:parse_methods(l:r, l:cp, l:methods_count)

  return {
  \   'magic': l:magic,
  \   'minor_version': l:minor,
  \   'major_version': l:major,
  \   'constant_pool': l:cp,
  \   'access_flags': l:flags,
  \   'this_class': l:this_class,
  \   'super_class': l:super_class,
  \   'interfaces': l:interfaces,
  \   'fields': l:fields,
  \   'methods': l:methods,
  \ }
endfunction

" Reader Helpers
function! s:new_reader(blob) abort
  return {
  \   'blob': a:blob,
  \   'offset': 0,
  \   'u1': function('s:read_u1'),
  \   'u2': function('s:read_u2'),
  \   'u4': function('s:read_u4'),
  \   'bytes': function('s:read_bytes'),
  \ }
endfunction

function! s:read_u1() dict abort
  let l:val = self.blob[self.offset]
  let self.offset += 1
  return l:val
endfunction

function! s:read_u2() dict abort
  let l:val = (self.blob[self.offset] * 256) + self.blob[self.offset + 1]
  let self.offset += 2
  return l:val
endfunction

function! s:read_u4() dict abort
  let l:val = (self.blob[self.offset] * 16777216) + (self.blob[self.offset + 1] * 65536) + (self.blob[self.offset + 2] * 256) + self.blob[self.offset + 3]
  let self.offset += 4
  return l:val
endfunction

function! s:read_bytes(len) dict abort
  let l:res = []
  let l:i = 0
  while l:i < a:len
    call add(l:res, self.blob[self.offset + l:i])
    let l:i += 1
  endwhile
  let self.offset += a:len
  return l:res
endfunction

" Constant Pool Parser
function! s:parse_cp(r, count) abort
  let l:cp = [{}] " 1-based index
  let l:i = 1
  while l:i < a:count
    let l:tag = a:r.u1()
    if l:tag == 1 " UTF8
      let l:len = a:r.u2()
      let l:bytes = a:r.bytes(l:len)
      let l:str = list2str(l:bytes)
      call add(l:cp, {'tag': 1, 'val': l:str})
    elseif l:tag == 3 " Integer
      let l:val = a:r.u4()
      if l:val >= 2147483648
        let l:val = l:val - 4294967296
      endif
      call add(l:cp, {'tag': 3, 'val': l:val})
    elseif l:tag == 4 " Float
      let l:val = a:r.u4()
      call add(l:cp, {'tag': 4, 'val': l:val})
    elseif l:tag == 5 " Long
      let l:high = a:r.u4()
      let l:low = a:r.u4()
      call add(l:cp, {'tag': 5, 'val': [l:high, l:low]})
      call add(l:cp, {}) " Takes 2 slots
      let l:i += 1
    elseif l:tag == 6 " Double
      let l:high = a:r.u4()
      let l:low = a:r.u4()
      call add(l:cp, {'tag': 6, 'val': [l:high, l:low]})
      call add(l:cp, {}) " Takes 2 slots
      let l:i += 1
    elseif l:tag == 7 " Class
      let l:name_idx = a:r.u2()
      call add(l:cp, {'tag': 7, 'name_index': l:name_idx})
    elseif l:tag == 8 " String
      let l:string_index = a:r.u2()
      call add(l:cp, {'tag': 8, 'string_index': l:string_index})
    elseif l:tag == 9 " Fieldref
      let l:class_idx = a:r.u2()
      let l:nt_idx = a:r.u2()
      call add(l:cp, {'tag': 9, 'class_index': l:class_idx, 'name_and_type_index': l:nt_idx})
    elseif l:tag == 10 " Methodref
      let l:class_idx = a:r.u2()
      let l:nt_idx = a:r.u2()
      call add(l:cp, {'tag': 10, 'class_index': l:class_idx, 'name_and_type_index': l:nt_idx})
    elseif l:tag == 11 " InterfaceMethodref
      let l:class_idx = a:r.u2()
      let l:nt_idx = a:r.u2()
      call add(l:cp, {'tag': 11, 'class_index': l:class_idx, 'name_and_type_index': l:nt_idx})
    elseif l:tag == 12 " NameAndType
      let l:name_idx = a:r.u2()
      let l:desc_idx = a:r.u2()
      call add(l:cp, {'tag': 12, 'name_index': l:name_idx, 'descriptor_index': l:desc_idx})
    elseif l:tag == 15 " MethodHandle
      let l:ref_kind = a:r.u1()
      let l:ref_idx = a:r.u2()
      call add(l:cp, {'tag': 15, 'reference_kind': l:ref_kind, 'reference_index': l:ref_idx})
    elseif l:tag == 16 " MethodType
      let l:desc_idx = a:r.u2()
      call add(l:cp, {'tag': 16, 'descriptor_index': l:desc_idx})
    elseif l:tag == 18 " InvokeDynamic
      let l:bm_idx = a:r.u2()
      let l:nt_idx = a:r.u2()
      call add(l:cp, {'tag': 18, 'bootstrap_method_attr_index': l:bm_idx, 'name_and_type_index': l:nt_idx})
    else
      throw 'Unknown constant pool tag: ' . l:tag
    endif
    let l:i += 1
  endwhile
  return l:cp
endfunction

" Methods Parser
function! s:parse_methods(r, cp, count) abort
  let l:methods = {}
  let l:i = 0
  while l:i < a:count
    let l:flags = a:r.u2()
    let l:name_idx = a:r.u2()
    let l:desc_idx = a:r.u2()
    let l:attr_count = a:r.u2()

    let l:name = a:cp[l:name_idx].val
    let l:desc = a:cp[l:desc_idx].val
    let l:key = l:name . l:desc

    let l:method = {
    \   'access_flags': l:flags,
    \   'name': l:name,
    \   'descriptor': l:desc,
    \   'max_stack': 0,
    \   'max_locals': 0,
    \   'code': [],
    \   'exception_table': [],
    \ }

    let l:j = 0
    while l:j < l:attr_count
      let l:attr_name_idx = a:r.u2()
      let l:attr_len = a:r.u4()
      let l:attr_name = a:cp[l:attr_name_idx].val

      if l:attr_name ==# 'Code'
        let l:method.max_stack = a:r.u2()
        let l:method.max_locals = a:r.u2()
        let l:code_len = a:r.u4()
        let l:method.code = a:r.bytes(l:code_len)

        let l:ex_len = a:r.u2()
        let l:ex_table = []
        let l:k = 0
        while l:k < l:ex_len
          let l:start_pc = a:r.u2()
          let l:end_pc = a:r.u2()
          let l:handler_pc = a:r.u2()
          let l:catch_type = a:r.u2()
          call add(l:ex_table, {
          \   'start_pc': l:start_pc,
          \   'end_pc': l:end_pc,
          \   'handler_pc': l:handler_pc,
          \   'catch_type': l:catch_type,
          \ })
          let l:k += 1
        endwhile
        let l:method.exception_table = l:ex_table

        " Skip sub-attributes of Code (e.g. LineNumberTable)
        let l:sub_attr_count = a:r.u2()
        let l:k = 0
        while l:k < l:sub_attr_count
          let l:sub_name_idx = a:r.u2()
          let l:sub_len = a:r.u4()
          let l:unused_bytes = a:r.bytes(l:sub_len)
          let l:k += 1
        endwhile
      else
        let l:unused_bytes = a:r.bytes(l:attr_len)
      endif
      let l:j += 1
    endwhile

    let l:methods[l:key] = l:method
    let l:i += 1
  endwhile
  return l:methods
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
