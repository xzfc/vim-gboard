" `gt` - goto clipboard
" License: This file is placed in the public domain.


if exists("g:loaded_gboard")
  finish
endif
let g:loaded_gboard = 1


let s:save_cpo = &cpo
set cpo&vim


if !exists("g:gboard_no_maps") || ! g:gboard_no_maps
  if has("nvim-0.4")
    call nvim_set_keymap('n', 'gb',      '<Plug>(gboard)',         { 'desc': 'Go to file in clipboard' })
    call nvim_set_keymap('n', 'gB',      '<Plug>(gboard:split)',   { 'desc': 'Go to file in clipboard (split)' })
    call nvim_set_keymap('n', '<C-W>gb', '<Plug>(gboard:tabedit)', { 'desc': 'Go to file in clipboard (tabedit)' })
  else
    " Sadly, Vim doesn't provide a way to set mapping description.
    " https://github.com/vim/vim/issues/12205
    nmap gb      <Plug>(gboard)
    nmap gB      <Plug>(gboard:split)
    nmap <C-W>gb <Plug>(gboard:tabedit)
  endif
endif


nnoremap <silent> <Plug>(gboard)          :<C-u>call <SID>goto_clipboard('edit')<CR>
nnoremap <silent> <Plug>(gboard:split)    :<C-u>call <SID>goto_clipboard('split')<CR>
nnoremap <silent> <Plug>(gboard:vsplit)   :<C-u>call <SID>goto_clipboard('vsplit')<CR>
nnoremap <silent> <Plug>(gboard:tabedit)  :<C-u>call <SID>goto_clipboard('tabedit')<CR>
nnoremap <silent> <Plug>(gboard:above)    :<C-u>call <SID>goto_clipboard('leftabove split')<CR>
nnoremap <silent> <Plug>(gboard:left)     :<C-u>call <SID>goto_clipboard('leftabove vsplit')<CR>
nnoremap <silent> <Plug>(gboard:below)    :<C-u>call <SID>goto_clipboard('rightbelow split')<CR>
nnoremap <silent> <Plug>(gboard:right)    :<C-u>call <SID>goto_clipboard('rightbelow vsplit')<CR>
nnoremap <silent> <Plug>(gboard:top)      :<C-u>call <SID>goto_clipboard('topleft split')<CR>
nnoremap <silent> <Plug>(gboard:leftest)  :<C-u>call <SID>goto_clipboard('topleft vsplit')<CR>
nnoremap <silent> <Plug>(gboard:bottom)   :<C-u>call <SID>goto_clipboard('botright split')<CR>
nnoremap <silent> <Plug>(gboard:rightest) :<C-u>call <SID>goto_clipboard('botright vsplit')<CR>


function s:goto_clipboard(opener)
  " Each candidate is a list of four items:
  "   0: full match
  "   1: file name
  "   2: line number
  "   3: column number
  let candidates = []

  " First, X11 primary selection ('*'), then clipboard ('+').
  for reg in [getreg('*'), getreg('+')]
    " 1. Whole content as a single filename.
    call add(candidates, [reg, reg, '', ''])

    " 2. Matches multi-line grep-like output. (see doc)
    call substitute(
          \ reg,
          \ '\v%(\n|^)(\f+)\n%(\d+[:-│].*\n)*(\d+):.*$',
          \ '\=add(candidates, [submatch(1) . ":" . submatch(2), submatch(1), submatch(2), ""])',
          \ 'g')

    " 3. Matches `foo.txt` or `foo.txt:10` or `foo.txt:10:5`.
    call substitute(
          \ reg,
          \ '\v(\f+)%(:(\d+)%(:(\d+))?)?',
          \ '\=add(candidates, [submatch(0), submatch(1), submatch(2), submatch(3)])',
          \ 'g')
  endfor

  for candidate in candidates
    let fname = candidate[1]
    if filereadable(fname)
      " All good
    elseif fname =~# '^[ab]/' && filereadable(fname[2:])
      " Strip git diff prefixes (a/ and b/)
      let fname = fname[2:]
    else
      " Not a valid filename
      continue
    endif

    echo 'Editing ' . candidate[0]

    if a:opener ==# 'edit' && fname == expand('%')
      if candidate[2] != ''
        execute 'normal! ' . candidate[2] . 'gg'
      endif
    else
      if candidate[2] != ''
        execute a:opener . ' +' . candidate[2] . ' ' . fnameescape(fname)
      else
        execute a:opener . ' ' . fnameescape(fname)
      endif
    endif

    if candidate[3] != ''
      execute 'normal! ' . candidate[3] . '|'
    endif

    return
  endfor

  echo "No valid filename found in the clipboard"
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
