" use pathogen.vim for managing plugins (https://github.com/tpope/vim-pathogen)
execute pathogen#infect()
syntax on
filetype plugin indent on

" don't need to be compatible with vi
set nocompatible
" supposedly this prevents security exploits, and I don't use it anyway
set modelines=0

" default indentation: 2 spaces
set ts=2 sts=2 sw=2 expandtab

""" basic options

set encoding=utf-8              " sane default file encoding
set scrolloff=3                 " minimum nuber of lines to keep above and below the cursor
set autoindent                  " use the indent of the current line for a new line
set showmode                    " show a message when in Insert, Replace, or Visual mode
set showcmd                     " show partial command in the last line on the screen
set hidden                      " buffer is hidden when abandoned (instead of unloaded)
set wildmenu                    " enhanced command line completion
set wildmode=list:longest       " list matches, and complete to the longest common string
set cursorline                  " highlight the screen line of the cursor
set ttyfast                     " indicates a fast terminal connection, should be smoother
set ruler                       " show the line and column of the cursor position
set backspace=indent,eol,start  " allow backspacing over these options in Insert mode
set laststatus=2                " always show the status line
" if exists('&relativenumber')
"   set relativenumber            " show line number relative to cursor line
" endif
set number                      " show line numbers
set title                       " show title in console title bar
let mapleader = " "             " set the leader key to space (easier to type than backslash)

" so that the vim keys are logged correctly
" from https://vi.stackexchange.com/a/14443
set t_RV=

""" searching/moving

set ignorecase                  " case insensitive search
set smartcase                   " any uppercase characters cause search to be case sensitive
set gdefault                    " use /g by default
set incsearch                   " show matches as you type
set showmatch                   " show matching brackets
set hlsearch                    " highlight search pattern matches
" get rid of search highlighting once I'm done with it
nnoremap <leader><space> :nohls<cr>
" use Tab to jump between bracket pairs ([{}])
nnoremap <tab> %
vnoremap <tab> %

""" long line handling

" set wrap                        " wrap long lines
" set textwidth=96                " at 96 chars I can fit 2 windows side-by-side in tmux
" set formatoptions=qrn1          " text formatting options
" " q - allows hard-wrapping comments with "gq"
" " r - automatically insert the current comment leader after <Enter> in Insert mode
" " n - recognize numbered lists
" " 1 - don't break a line after a 1-letter word

""" whitespace

"set list                        " leave this off, since it's distracting
set listchars=tab:▸\ ,eol:¬     " use the same symbols as TextMate for tabstops and EOLs
" strip trailing whitespace before file write
autocmd BufWritePre * :call StripTrailingWhitespace()

""" do the right thing - no arrow keys (also disables mouse scrolling)

nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
" move by screen line instead of file line
nnoremap j gj
nnoremap k gk

""" annoyances

" get rid of that stupid F1 key that I hit accidentally when aiming for escape
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>
" save when focus is lost
autocmd FocusLost * :wa
" easy toggle for pasting text without the crazy indentation
set pastetoggle=<F2>
" disable scrollbars (annoying in macvim)
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L
" don't flash the screen or do any bells, which are annoying
" (from http://vim.wikia.com/wiki/Disable_beeping)
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

""" misc commands

" select the text that was just pasted, so I can do things to it
nnoremap <leader>v V`]
" search and replace the word under the cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>/
" open split (with '|' or '-'), then open file browser
nnoremap <leader>\| <C-w>v<C-w>l:e.<CR>
nnoremap <leader>- <C-w>s<C-w>j:e.<CR>
" use ack in vim
nnoremap <leader>a :Ack

""" edit my vimrc

nmap <leader>ev :e $MYVIMRC<CR>
nmap <leader>sv :so $MYVIMRC<CR>

""" filetype styles

autocmd FileType ruby setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType vim setlocal ts=2 sts=2 sw=2 expandtab

""" syntax highlighting

" syntax highlighting, with a nice colorscheme
syntax enable
colorscheme wombat
" line numbers should be grey
hi LineNr       ctermfg=darkGrey
" make the Ubuntu terminal look better
if $COLORTERM == 'gnome-terminal'
  set t_Co=256
endif

""" functions

" remove trailing whitespace
function! StripTrailingWhitespace()
  " save search and cursor position
  let _s=@/
  let l = line(".")
  let c = col(".")
  " regex to strip whitespace at the end of lines
  %s/\s\+$//e
  " restore search history and cursor position
  let @/=_s
  call cursor(l,c)
endfunction

""" plugins

" NERDTree (no longer using this)
" show hidden files
" let NERDTreeShowHidden=1
" use instead of  netrw (this is the default)
" let g:NERDTreeHijackNetrw = 1
" open blank initial window so that NERDTree doesn't disappear on the first file open
" (from https://stackoverflow.com/a/36882670/)
" autocmd VimEnter NERD_tree_1 enew | execute 'NERDTree '.argv()[0]

" netrw (built-in)
" hide these file extensions (from https://stackoverflow.com/a/21020164/)
let g:netrw_list_hide= '.*\.swp$,\~$,\.orig$'

" statusline things (from https://stackoverflow.com/a/32059626 and https://stackoverflow.com/a/45244610)
" [buffer number] followed by relative path to file:
set statusline=[%n]\ %{expand('%:~:.')}

" syntastic settings
" (from https://medium.com/@hpux/vim-and-eslint-16fa08cc580f)
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
" thanks to https://github.com/vim-syntastic/syntastic/issues/2102
" (script in $DOTFILES/scripts/)
let g:syntastic_javascript_eslint_exec = 'eslint-for-vim'
let g:syntastic_javascript_eslint_exe = 'npm run lint --'
" disable syntastic by default, but allow toggling this when I want it
" (adapted from https://stackoverflow.com/a/21434697)
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
nnoremap <leader>E :SyntasticCheck<CR> :SyntasticToggleMode<CR>

" show line#:column# on the right hand side
set statusline+=%=%l:%c

" CtrlP
" command mapping
let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlP'
" set the local working directory to project root
let g:ctrlp_working_path_mode = 'ra'
" ignore these directories
set wildignore+=*/vendor/**
set wildignore+=*/target/**

" font
" (install IBM plex font from https://github.com/IBM/plex)
if has("mac") || has("macunix")
  set gfn=IBM\ Plex\ Mono:h14,Source\ Code\ Pro:h15,Menlo:h15
endif

" Open markdown files with Chrome (on OSX)
" (adapted from https://stackoverflow.com/a/14718908 and https://stackoverflow.com/a/21187692)
" and using Markdown Preview Plus (https://chrome.google.com/webstore/detail/markdown-preview-plus/febilkbfcbhebfnokafefeacimjdckgl)
autocmd BufEnter *.md exe 'noremap <leader>m :!open -a "Google Chrome" %:p<CR>'
