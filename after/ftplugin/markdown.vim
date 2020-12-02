if &cp || exists("b:did_ftplugin_notebook_markdown")
  finish
else
  let b:did_ftplugin_notebook_markdown = 1
endif

let b:undo_ftplugin = get(b:, "undo_ftplugin", "exe") .
  \ "|unlet b:did_ftplugin_notebook_markdown"

let s:notebook_path = notebook#path()

" We need to check if the function exists already since invoke :edit. That
" causes a reload of this file before the function is done running, which will
" throw E127
if !exists("*s:EditMarkdownLink")
  function! s:EditMarkdownLink(link)
    if a:link
      let target = a:link
    else
      let target = matchstr(getline('.'), '\v\[[^\]]+]\(\zs[^\)]+\ze\)')
    endif

    if target == ''
      return
    endif

    " Doesn't work
    " let target = fnamemodify(target, ':p')
    if target !~ '^' . s:notebook_path
      let target = s:notebook_path . '/' . target
    endif


    if !isdirectory(target) && !file_readable(target)
      if s:AskToCreateFile(target)
        let dir = target[-1:] == "/" ? target : fnamemodify(target, ':p:h')

        if !isdirectory(dir)
          call mkdir(dir, "p")
        endif
      else
        return
      endif
    endif

    exe 'edit' target
  endfunction
endif

function! s:AskToCreateFile(file)
  let type = a:file[-1:] == "/" ? "Directory" : "File"
  let msg = printf("%s '%s' does not exist, create it?", type, a:file)

  return confirm(msg, "&No\n&Yes") == 2
endfunction

function! s:gf(file)
  " For some reason this doesn't open filebeagle if it is a directory :(
  " try
  "   normal! gf
  " catch /^Vim\%((\a\+)\)\=:E447:/
  "   call s:EditMarkdownLink(a:file)
  " endtry
    call s:EditMarkdownLink(a:file)
endfunction

let s:self = expand("%:p")

if notebook#path_in_notebook(s:self)
  " Enter on a line with a markdown link opens the first one
  nnoremap <silent><buffer> <cr> :call <SID>EditMarkdownLink('')<cr>
  let b:undo_ftplugin .= "|sil! nunmap <buffer> <cr>"

  map <silent><buffer> gf :call <SID>gf(expand('<cfile>'))<cr>
  let b:undo_ftplugin .= "|sil! unmap <buffer> gf"

  " Skip to prev/next markdown heading with a YYYY-MM-DD prefix
  nnoremap <silent><buffer> [d :<C-U>call search('\%(^#\{1,5\}\s\+\d\{4\}-\d\{2\}-\d\{2\}\\|^\d\{4\}-\d\{2\}-\d\{2\}.*\n^[=-]\+$\)', "bsW")<CR>
  nnoremap <silent><buffer> ]d :<C-U>call search('\%(^#\{1,5\}\s\+\d\{4\}-\d\{2\}-\d\{2\}\\|^\d\{4\}-\d\{2\}-\d\{2\}.*\n^[=-]\+$\)', "sW")<CR>
  xnoremap <silent><buffer> [d :<C-U>exe "normal! gv"<Bar>call search('\%(^#\{1,5\}\s\+\d\{4\}-\d\{2\}-\d\{2\}\\|^\d\{4\}-\d\{2\}-\d\{2\}.*\n^[=-]\+$\)', "bsW")<CR>
  xnoremap <silent><buffer> ]d :<C-U>exe "normal! gv"<Bar>call search('\%(^#\{1,5\}\s\+\d\{4\}-\d\{2\}-\d\{2\}\\|^\d\{4\}-\d\{2\}-\d\{2\}.*\n^[=-]\+$\)', "sW")<CR>
  let b:undo_ftplugin .= '|sil! nunmap <buffer> [d|sil! nunmap <buffer> ]d|sil! xunmap <buffer> [d|sil! xunmap <buffer> ]d'

  " Templates, eg ,nts for [n]otebook [t]emplate [s]standup,
  " inserts templates/standup.md from the notebook path
  nnoremap <silent><expr> <leader>nt ':<C-U>call notebook#template#insert("' . nr2char(getchar()) .'")<cr>'
  let b:undo_ftplugin .= '|sil! nunmap <leader>nt'

  let g:goyo_width = 120

  nnoremap <silent><buffer> <leader>g :Goyo<cr>

  if 0
    " Enable folding
    " not sure if I like it
    setlocal foldexpr=MarkdownFold()
    setlocal foldmethod=expr
    setlocal foldtext=MarkdownFoldText()
    setl foldlevel=1
    let b:undo_ftplugin .= "|setl foldexpr< foldmethod< foldtext< | exe 'normal! zE'"
  endif

  iabbrev <expr><buffer> {NOW} strftime('%-l:%M:%S%p')

  setlocal colorcolumn=

  " command! -buffer -nargs=1 TemplateInsert call notebook#template#insert('1')<cr>

  " if s:self =~# '^' . notebook#path_join('1:1s/')
  "   nnoremap <silent> <leader>nt :<C-U>call notebook#template#insert("1")<cr>
  " elseif s:self =~# '^' . notebook#path_join('mgmt/standup.md')
  "   nnoremap <silent> <leader>nt :<C-U>call notebook#template#insert("s")<cr>
  " endif

  " set mouse=a
  " setl indentexpr=

  " doautocmd User Notebook

  " execute 'syn region mkdStrike matchgroup=htmlStrike start="\%(\~\~\)" end="\%(\~\~\)" concealends'
  "
  " syn include @liquidYamlTop syntax/yaml.vim
  " unlet! b:current_syntax
  " syn region liquidYamlHead start="\%^---$" end="^---\s*$" keepend contains=@liquidYamlTop,@Spell

  let b:StripperStripOnSave = 1

  nnoremap <leader>gc :Git commit -m "Add today's <c-r>=fnamemodify(expand('%'), ':t:r')<cr>"<left>
  let b:undo_ftplugin .= '|sil! nunmap <leader>gc'
endif
