" " Rotate arguments
" " nnoremap <buffer> <localleader>rl :RotateArgsRight<CR>
" " nnoremap <buffer> <localleader>rh :RotateArgsLeft<CR>

" Run mtgeblack on the current file BB_SPECIFIC
command! -buffer Black !mtgeblack %
nnoremap <buffer> <localleader>f :Black<CR>

" Don't hard wrap lines despite what polyglot (??) might say
set formatoptions-=t
