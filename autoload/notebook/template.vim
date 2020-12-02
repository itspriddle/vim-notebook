let g:notebook#template#tags = {}

function! notebook#template#tags.date(string) dict abort
  if a:string !~# '{{DATE\(|[^}]\+\)\?}}'
    return a:string
  end

  if a:string =~# '{{DATE}}'
    let date_format = '%Y-%m-%d'
  else
    let date_format = matchstr(a:string, '{{DATE|\zs[^}]\+\ze}}')
  endif

  return substitute(a:string, '{{DATE\(|[^}]\+\)\?}}', strftime(date_format), '')
endfunction

function! s:format_line(line) abort
  let out = a:line

  for tag_name in keys(g:notebook#template#tags)
    let out = g:notebook#template#tags[tag_name](out)
  endfor

  return out
endfunction

function! notebook#template#insert(key) abort
  let notebook_path = notebook#path()

  let templates = {
    \ "s": notebook_path . "/templates/standup.md",
    \ "1": notebook_path . "/templates/1-1.md"
    \ }

  if !has_key(templates, a:key)
    call notebook#warn("No template for " . a:key)
    return
  endif

  let file = templates[a:key]

  let lines = readfile(file)

  if len(lines) == 0
    return
  endif

  call map(lines, 's:format_line(v:val)')

  " if len(lines) > 1
  "   call setline(".", lines[0])
  " endif

  " call add(lines, '')
  " call append(line('.'), lines[1:])
  call append(line('.'), lines)
endfunction
