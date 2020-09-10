if has('win32') || has('win64')
	let $VIMHOME = $HOME."/vimfiles"
else
	let $VIMHOME = $HOME."/.vim"
endif

" Plugins
call plug#begin()
Plug 'sheerun/vim-polyglot'							" Language support
" Tim Poe
Plug 'tpope/vim-vinegar'								" Make netrw a little nicer
Plug 'tpope/vim-surround'								" More functionality for changing text surrounded by stuff
Plug 'tpope/vim-fugitive'								" Doing git stuff from vim
Plug 'tpope/vim-rhubarb'								" The hub to fugitive's git
Plug 'tpope/vim-repeat'									" Make . work for some plugin action too (by default surround, speeddating, unimpaired, easyclip)
Plug 'tpope/vim-unimpaired'							" Expand the mappings for [] movements
Plug 'tpope/vim-sensible'								" Sensible defaults, replacing a lot of my settings
Plug 'tpope/vim-commentary'							" Comment with gc
Plug 'tpope/vim-abolish'								" Do a few things relating to variations of text
" Junegunn
Plug 'junegunn/gv.vim'									" Git commit browser for fugitive from junegunn
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } 
Plug 'junegunn/fzf.vim'
" Misc
Plug 'SirVer/ultisnips'									" Snippets
Plug 'dense-analysis/ale'								" Asynchronous Linting Engine
Plug 'chrisbra/Recover.vim'							" Diff swap files
Plug 'wesQ3/vim-windowswap'							" Swap splits without thinking about layout
Plug 'romainl/vim-cool'									" Better hlsearch behavior
Plug 'markonm/traces.vim'								" preview command line things like :s, :g, etc
Plug 'ludovicchabant/vim-gutentags'			" Automated tag generation
Plug 'romainl/vim-qf'										" Tame the quickfix menu
Plug 'yssl/QFEnter'											" Open quickfix item in last focused window
Plug 'editorconfig/editorconfig-vim'		" Use editor config files
Plug 'PeterRincker/vim-searchlight'			" Highlight current search match
Plug 'wellle/targets.vim'								" Extend usability of text objects
call plug#end()

"" FUNCTIONS
" Open the current buffer in a new tab and call git status
function! GS()
	tab split
	Gstatus
	resize 10
endfunction
command! GS call GS()


" Put current file and linenum into anonymous register
command! YankLinenum redir @" | echon expand('%:p')':'line('.') | redir END
command! YL YankLinenum

" When using `dd` in the quickfix list, remove the item from the quickfix list.
function! RemoveQFItem()
	let curqfidx = line('.') - 1
	let qfall = getqflist()
	call remove(qfall, curqfidx)
	call setqflist(qfall, 'r')
	execute curqfidx + 1 . "cfirst"
	:copen
endfunction
:command! RemoveQFItem :call RemoveQFItem()
" Use map <buffer> to only map dd in the quickfix window. Requires +localmap
autocmd FileType qf map <buffer> dd :RemoveQFItem<CR>

function! GetSelectedText()
	normal gv"xy
	let result = getreg("x")
	return result
endfunction

function! Leap(forwards) " TODO: Make this a plugin
	let l:jump_list_info = getjumplist()
	let l:current_jump = l:jump_list_info[1]

	let l:previous_jumps = l:jump_list_info[0][:l:current_jump - 1]
	let l:next_jumps = l:jump_list_info[0][l:current_jump + 1:]
	let l:current_buffer = bufnr('%')

	let l:candidate_jumps = (a:forwards ? l:next_jumps : reverse(l:previous_jumps))
	" There's got to be a more elegant way to do this but I'm a noob
	let l:jumps = 0
	for i in l:candidate_jumps
		let l:jumps += 1
		if i['bufnr'] != l:current_buffer
			execute "normal! ".l:jumps.(a:forwards ? "\<C-i>" : "\<C-o>")
			return
		endif
	endfor

	" If we haven't jumped by this point that means all the candidate jumps are in the same buffer
	" In that case we still want to jump as far as possible
	execute "normal! ".max([1, len(l:candidate_jumps)]).(a:forwards ? "\<C-i>" : "\<C-o>")
endfunction

" lcd to the directory of the current buffer
command! LCD lcd %:p:h
" delete the current buffer, leaving the previous buffer in its place
command! -bang BD buffer #<bar>bdelete<bang> #

" Save the current buffer and source it (for vimrc files and snippets)
augroup vim_commands
	autocmd!
	autocmd BufEnter *.vim command! W w | so %
	autocmd BufEnter vimrc command! W w | so %
	autocmd BufEnter *.snippets command! W w | call UltiSnips#RefreshSnippets()
augroup END

" Rename the current buffer
command! -complete=file -nargs=1 Rename saveas %:h/<args> | !rm #

function! QuickFix_Toggle()
	for i in range(1, winnr('$'))
		let bnum = winbufnr(i)
		if getbufvar(bnum, '&buftype') == 'quickfix'
			cclose
			return
		endif
	endfor
	copen
endfunction

command! -nargs=1 GQ Gpull | Git add --all | Git commit -m "<args>" | Gpush

"" SETTINGS
if has('win32')
	colorscheme desert
endif

" Disable bells, they're particularly annoying with Alt- ESC method
set noeb vb t_vb=

" Cool colors
set termguicolors

" Increase scrollback in :terinal normal mode. Default is 10000
set termwinscroll=100000

" ### PARAMOUNT ### "
colorscheme paramount-custom " TODO: Make this a real plugin
set background=dark

" Search all lower = insensitive, any upper = sensitive
set ignorecase
set smartcase
set infercase
" highlight searches
set hlsearch
" default to utf-8 encoding
set encoding=utf-8
" hide buffers that are unsaved
set hidden
" disable annoying sticky comments
set formatoptions-=cro
" wildmode list in mru order, then scroll through options
set wildmenu
set wildmode=list:lastused,full
" wildcharm does the same thing as <Tab>, but can be used in mapping where <Tab> doesn't work
set wildcharm=<C-z>
" make the mouse work in console vim
set mouse=a
" show the command I'm cooking up in the bottom right of the screen
set showcmd
" modeline can be used for file-specific settings declared at the top of the file,
" unfortunately it currently has a vulnerability allowing arbitrary code execution
set nomodeline
" Set the default textwidth
set textwidth=100
" Try these suffixes for things like gf
set suffixesadd+=.yml,.py,.cpp,.h,.md
" Color column at textwidth
set colorcolumn=+0
highlight ColorColumn guibg=#353535
" Always open diffs in vertical splits
set diffopt+=vertical
" Use histogram and indent-heuristic for nicer vimdiff
if has('nvim-0.3.2') || has("patch-8.1.0360")
	set diffopt+=algorithm:histogram,indent-heuristic
endif
" Set shift tab sequence in non-neovim
if !has('nvim')
	set t_kB=[Z
endif

" My tabs should default to 2 spaces, to be ideally overriden by .editorconfig
set shiftwidth=0 " if 0, use value of tabstop
set softtabstop=-1 " If negative, use value of shiftwidth (which uses tabstop)
set tabstop=2

" Show the number of matches for a search in the bottom right corner
set shortmess-=S

" By default, stop syntax highlighting past 20,000 lines
syntax sync minlines=20000

" Gui options
if has("gui_running")
	" Use non-gui tabline
	set guioptions-=e
	" gvim settings to remove menu bar and toolbar
	set guioptions-=m
	set guioptions-=T
	" gvim remove lefthand scrollbar
	set guioptions-=L
	set guioptions-=r
	" set gvim font
	set guifont=Source\ Code\ Pro\ 13,Consolas:h14:cANSI
	" don't blink cursor
	set guicursor+=a:blinkon0
endif

"******** PATH STUFF ********" TODO: Make this a plugin
let g:path_map={"default": ",**,"}

function s:get_shallowest_directory()
	return strpart(getcwd(), (strridx(getcwd(), '/') + 1))
endfunction

function! SetCDPath()
	let l:shallowest_dir = s:get_shallowest_directory()
	let g:path_key = has_key(g:path_map, l:shallowest_dir) ? l:shallowest_dir : "default"

	execute "set path=".get(g:path_map, g:path_key)
endfunction
" Set path on startup
command! SetCDPath call SetCDPath()
SetCDPath

augroup me
	autocmd!
	" associate .p8 files with the lua filetype
	autocmd BufNewFile,BufRead *.p8 setlocal ft=lua
	" associate .script files with the lua filetype
	autocmd BufNewFile,BufRead *.script setlocal ft=lua

	" :make on a py file calls pylint and passes issues to quickfix
	autocmd FileType python set makeprg=pylint\ --reports=n\ --msg-template=\"{path}:{line}:\ {msg_id}\ {symbol},\ {obj}\ {msg}\"\ %:p
	autocmd FileType python set errorformat=%f:%l:\ %m


	" Change path based on current directory
	autocmd DirChanged window SetCDPath
	autocmd DirChanged tabpage SetCDPath
	autocmd DirChanged global SetCDPath
	autocmd WinEnter * SetCDPath
augroup END

" Use ag for :grep and :lgrep
if executable('ag')
	set grepprg=ag\ --vimgrep
endif

" Use the unnamed register for interaction with the clipboard
set clipboard+=unnamed
set clipboard+=unnamedplus

" completion options
set completeopt=menu,menuone

" default foldmethod for simplicity
set foldmethod=indent
" Kinda hacky way of defaulting to unfolded
set foldlevel=99

" toggle all folded
nnoremap <expr> z<Space> &foldlevel == 0 ? ":set foldlevel=99<CR>" : ":set foldlevel=0<CR>"

" Highlight tabs - hopefully this isn't too slow
augroup HiglightTabs
	autocmd!
	highlight Tabs guibg=#353535
	autocmd WinEnter,VimEnter * :silent! call matchadd("Tabs", "\t", -1)
augroup END

" Define tags only by line number, reduces filesize and help with some other things at the cost of
" potentially getting out of sync. Fortunately, we regen tags file all the time.
let g:gutentags_ctags_extra_args = ["-n"]

function! GetPathKey()
	return g:path_key
endfunction

function! SetStatusLine()
	set statusline=
	set statusline+=%1*%{getcwd()}\/
	set statusline+=%0*%f
	set statusline+=%0*\ %m

	set statusline+=%=

	set statusline+=%{gutentags#statusline()}
	set statusline+=[%{GetPathKey()}]
	set statusline+=%{FugitiveStatusline()}
	set statusline+=\ %y
	set statusline+=\ %l:%c
	set statusline+=\ %P
endfunction
command! SetStatusLine call SetStatusLine()
SetStatusLine

" EditorConfig settings
let g:EditorConfig_exclude_patterns = ['fugitive://.\*', 'scp://.\*']

" Copied from fzf.vim docs
" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

" always enable preview window and put it on the left
let g:fzf_preview_window = 'right:50%'
function! s:p(bang, ...) " Copied from fzf source
	let preview_window = get(g:, 'fzf_preview_window', a:bang && &columns >= 80 || &columns >= 120 ? 'right': '')
	if len(preview_window)
		return call('fzf#vim#with_preview', add(copy(a:000), preview_window))
	endif
	return {}
endfunction


"" KEYS
" ===== LEADER MAPPINGS ===== "
nnoremap <Space> <Nop>
let mapleader=" "
let maplocalleader="\\"

" Files in CD
nnoremap <leader>e :Files<CR>
" Buffers
nnoremap <leader>b :Buffers<CR>

" grep
function! FZFRgDir(bang, ...)
	let directory = a:0 >= 1 ? a:1 : ""
	let query_list = a:0 >=2 ? a:000[1:] : [""]
	let query = join(query_list)

	call fzf#vim#grep(
				\ "rg --column --line-number --no-heading --color=always --smart-case -- ".shellescape(query),
				\ 1,
				\ s:p(a:bang, {'dir': directory, 'options': '--delimiter : --nth 4..'}),
				\ a:bang)
endfunction

command! -complete=file -bang -nargs=* RG call FZFRgDir(<bang>0, <f-args>)

nnoremap <leader>f :RG<CR>
nnoremap <leader>8f :RG . <C-r><C-w><CR>
" Tags
command! -bang -nargs=* TG
			\ call fzf#vim#tags(<q-args>,
			\     s:p(<bang>0, {'placeholder': '{2}:{3}', 'options': ['-d', "\t", '-n', '1']}),
			\     <bang>0)
nnoremap <leader>] :TG<CR>

" Open a new tab
nnoremap <leader>gt :tab split<CR>
nnoremap <leader>gT :-tab split<CR>
" Close the current tab
nnoremap <leader>gk :tabc<CR>
nnoremap <leader>gK :tabc<CR>gT
" Go to tab by number
let s:number = 0
while s:number < 10
	execute 'nnoremap g' . s:number . ' ' . s:number . 'gt'
	let s:number += 1
endwhile

" Open a terminal in the current split
nnoremap <leader><CR> :term ++curwin<CR>
" Split controls
nnoremap <leader>h :vsp<CR>
nnoremap <leader>j :sp<CR><C-w><C-j>
nnoremap <leader>k :sp<CR>
nnoremap <leader>l :vsp<CR><C-w><C-l>

" Search for the current visual selection
xnoremap * y/\V<C-r>0<CR>

" Shorten window swapping command
let g:windowswap_map_keys = 0 " prevent default bindings
nnoremap <silent> <C-w><C-w> :call WindowSwap#EasyWindowSwap()<CR>
tnoremap <silent> <C-w><C-w> <C-w>:call WindowSwap#EasyWindowSwap()<CR>

" ===== RE-MAPPINGS ===== "
" swap gj j, gk k
" if prepended with a count, j and k work as normal
nnoremap <expr> j (v:count ? 'j' : 'gj')
nnoremap <expr> k (v:count ? 'k' : 'gk')
nnoremap gj j
nnoremap gk k
" Swap gF and gf
nnoremap gf gF
nnoremap gF gf
vnoremap gf gF
vnoremap gF gf
" Swap ' and `
for first in ['', 'g', '[', ']']
	for mode in ['n', 'x', 'o']
		execute mode . 'noremap ' . first . "' " . first . "`"
		execute mode . 'noremap ' . first . "` " . first . "'"
	endfor
endfor

" Bring Y in line with D and C
nnoremap Y y$

" map ., and ,. (and shift+those) to .* in insert and commnad line modes for easier globbing in regex patterns
noremap! ., .*
noremap! ,. .*
noremap! <> .*
noremap! >< .*

" Open the vimrc, this mapping shadows some select mode thing, but I've never intentionally used
" select mode anyway
nnoremap gh :drop $MYVIMRC<CR>

" Open ~/note/note.md
command! OpenNote drop ~/note/note.md | normal G
nnoremap <leader>n :OpenNote<CR>
" Find tag with grep
function! NoteTags(...)
	let tag = a:0 == 1 ? a:1 : ""
	if tag == ""
		silent grep! '\B\#[A-Za-z]' ~/note/note.md | redraw!
	else
		execute "silent grep! '\\B\\#".tag."' ~/note/note.md | redraw!"
	endif
endfunction

command! -nargs=? NT call NoteTags(<f-args>)

" FZF in note.md
command! NF RG ~/note/

" Make CTRL+Backspace work in insert mode... I feel like this worked before but idk
inoremap  <C-w>

" ===== WINDOW MAPPINGS ===== "
" Terminal mappings
tnoremap <C-v> <C-w>"+
tnoremap <C-w><C-n> <C-w>N
nnoremap <C-w><C-n> A
tnoremap  <C-w>:b #<CR>

" Refresh terminal
tnoremap <C-l> <C-w>Na

" Toggle the quickfix window
nnoremap <silent> <F2> :call QuickFix_Toggle()<CR>

" ===== OTHER STUFF... ===== "
" Snippet mapping
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" For conceal markers.
if has('conceal')
	set conceallevel=2 concealcursor=niv
endif

if executable("clip.exe")
	" Copy to windows clipboard from visual mode
	vnoremap <C-c> :call system('clip.exe', GetSelectedText())<CR>
	vnoremap <C-x> :call system('clip.exe', GetSelectedText())<CR>gvx
endif

" Leaps!
nnoremap <silent> <leader>o :call Leap(0)<CR>
nnoremap <silent> <leader>i :call Leap(1)<CR>
nnoremap <Left> :call Leap(0)<CR>
nnoremap <Right> :call Leap(1)<CR>

" I never want to accidentally do this
nnoremap <C-w>o :echo "Use :on[ly]"<CR>
nnoremap <C-w><C-o> :echo "Use :on[ly]"<CR>
tnoremap <C-w>o <C-w>:echo "Use :on[ly]"<CR>
tnoremap <C-w><C-o> <C-w>:echo "Use :on[ly]"<CR>

" Toggle text filetype
function! FiletypeTextToggle()
	if !exists("b:previous_filetype")
		let b:previous_filetype=&filetype
		set filetype="text"
	else
		let &filetype=b:previous_filetype
		unlet b:previous_filetype
	endif
endfunction
command! FTT call FiletypeTextToggle()

" Use incsearch highlighting for searchlight
highlight link Searchlight Incsearch

" Auto reply to list-like commands
function! AutoReply()
  let previous_cmdline  = histget('cmd', -1)
  let previous_cmd      = split(previous_cmdline)[0]
  let previous_args     = split(previous_cmdline)[1:]

  let ignorecase    = &ignorecase
  set noignorecase
  let previous_cmd  = get(getcompletion(previous_cmd, 'command'), 0)
  let &ignorecase   = ignorecase

  if empty(previous_cmd)
    return
  endif

  if previous_cmd ==# 'global'
    call feedkeys(':')
  elseif previous_cmd ==# 'undolist'
    call feedkeys(':undo' . ' ')
  elseif previous_cmd ==# 'oldfiles'
    call feedkeys(':edit #<')
  elseif previous_cmd ==# 'marks'
    call feedkeys(':normal! `')

  elseif previous_cmd ==# 'changes'
    call feedkeys(':normal! g;')
    call feedkeys("\<S-Left>")
  elseif previous_cmd ==# 'jumps'
    call feedkeys(':normal!' . ' ')
    call feedkeys("\<C-O>\<S-Left>")

  elseif index(['ls', 'files', 'buffers'], previous_cmd) != -1
    call feedkeys(':b' . ' ')
  elseif index(['clist', 'llist'], previous_cmd) != -1
    call feedkeys(':silent' . ' ' . repeat(previous_cmd[0], 2) . ' ')
  elseif index(['dlist', 'ilist'], previous_cmd) != -1
    call feedkeys(':' . previous_cmd[0] . 'jump' . ' ' . join(previous_args))
    call feedkeys("\<Home>\<S-Right>\<Space>")
  endif
endfunction

augroup AutoReply
  autocmd!
  autocmd CmdlineLeave : call AutoReply()
augroup END
