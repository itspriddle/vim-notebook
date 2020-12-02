" notebook.vim
" Author:  Joshua Priddle <jpriddle@me.com>
" Version: 0.0.0
" License: Same as Vim itself (see :help license)

if &cp || exists("g:notebook_loaded") && g:notebook_loaded
  finish
else
  let g:notebook_loaded = 1
endif

function! s:Notebook(edit_cmd)
  let path = notebook#path()

  if !isdirectory(path)
    call notebook#utils#warn(printf("Couldn't find notebook directory '%s'", s:notebook_path))
    return
  endif

  exe "lcd" path
  exe a:edit_cmd "index.md"
endfunction

command! Notebook call s:Notebook('edit')
command! TNotebook call s:Notebook('tabnew')
command! SNotebook call s:Notebook('split')
command! VNotebook call s:Notebook('vsplit')

nnoremap <leader>nn :call <SID>Notebook('edit')<cr>

" TODO: conceal for strikeout text

" augroup notebook
"   autocmd!
"   autocmd User Notebook set mouse=a
" augroup END
