function! notebook#warn(...) abort
  echohl WarningMsg
  echomsg call('printf', a:000)
  echohl None
endfunction

function! notebook#path()
  return resolve(expand(get(g:, "notebook_path", "~/work/notebook")))
endfunction

function! notebook#path_join(...)
  return join(insert(copy(a:000), notebook#path()), '/')
endfunction

function! notebook#path_in_notebook(path)
  let base = notebook#path() . '/'
  let path = resolve(expand(a:path))
  return path[0:len(base) - 1] == base
  " return a:path =~# '^' . notebook#path() .
endfunction
