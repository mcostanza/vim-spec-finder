" Find the related spec for any file you open.
function! s:RelatedSpec()
  let l:fullpath = expand("%:p")
  let l:filepath = expand("%:h")
  let l:fname = expand("%:t")

  let l:app_path_prefixes = [
  \ "app/",
  \ "assets/",
  \ "src/",
  \ ]

  let l:filepath_without_app = l:filepath
  for app_path_prefix in l:app_path_prefixes
    let l:filepath_without_app = substitute(l:filepath_without_app, app_path_prefix, "", "")
  endfor

  " Possible names for the spec/test for the file we're looking at
  let l:test_names = [
  \   substitute(l:fname, ".rb$", "_spec.rb", ""),
  \   substitute(l:fname, ".rb$", "_test.rb", ""),
  \   substitute(l:fname, '.\(j\|t\)s$', '_spec.\1s', ""),
  \   substitute(l:fname, '.\(j\|t\)sx$', '_spec.\1s', ""),
  \   substitute(l:fname, '.\(j\|t\)sx$', '_spec.\1sx', "")
  \ ]

  " Possible paths
  let l:test_paths = [
  \ "spec",
  \ "fast_spec",
  \ "test"
  \ ]

  for test_name in l:test_names
    for path in l:test_paths
      let l:spec_path = path . "/" . l:filepath_without_app . "/" . test_name
      let l:full_spec_path = substitute(l:fullpath, l:filepath . "/" . l:fname, l:spec_path, "")
      if filereadable(l:spec_path)
        return l:full_spec_path
      end
    endfor
  endfor
endfunction

" Find the file being tested when looking at a spec
function! s:FileRelatedToSpec()
  let l:fullpath = expand("%:p")
  let l:filepath = expand("%:h")
  let l:fname = expand("%:t")

  let l:related_file = substitute(l:filepath, "fast_spec/", "", "")
  let l:related_file = substitute(l:related_file, "spec/", "", "")
  let l:related_file = substitute(l:related_file, "test/", "", "")

  " Possible paths
  let l:test_paths = [
  \ "spec/",
  \ "fast_spec/",
  \ "test/"
  \ ]

  let l:related_file_names = [
  \   substitute(l:fname, "_spec.rb$", ".rb", ""),
  \   substitute(l:fname, '_spec.\(j\|t\)s$', '.\1s', ""),
  \   substitute(l:fname, '_spec.\(j\|t\)s$', '.\1sx', ""),
  \   substitute(l:fname, '_spec.\(j\|t\)sx$', '.\1sx', "")
  \ ]

  let l:app_paths = [
  \ "app/",
  \ "app/assets/",
  \ "src/",
  \ ]

  for related_file_name in l:related_file_names
    for possible_app_path in l:app_paths
      let l:full_file_path = substitute(l:fullpath, l:filepath . "/" . l:fname, possible_app_path . l:related_file . "/" . related_file_name, "")
      if filereadable(l:full_file_path)
        return l:full_file_path
      end
    endfor
  endfor
endfunction

" If looking at a regular file, find the related spec
" If looking at a spec, find the related file
function! s:RelatedSpecOrFile()
  let l:fname = expand("%:t")
  if match(l:fname, "_spec") != -1 || match(l:fname, "_test") != -1
    let l:result = s:FileRelatedToSpec()
  else
    let l:result = s:RelatedSpec()
  endif

  return l:result
endfunction

function! s:RelatedSpecOpen()
  let l:spec_path = s:RelatedSpecOrFile()
  if filereadable(l:spec_path)
    execute ":e " . l:spec_path
  endif
endfunction

function! s:RelatedSpecVOpen()
  let l:spec_path = s:RelatedSpecOrFile()
  if filereadable(l:spec_path)
    execute ":botright vsp " . l:spec_path
  endif
endfunction

command! RelatedSpecVOpen call s:RelatedSpecVOpen()
command! RelatedSpecOpen call s:RelatedSpecOpen()

nnoremap <silent> <C-s> :RelatedSpecVOpen<CR>
nnoremap <silent> ,<C-s> :RelatedSpecOpen<CR>
