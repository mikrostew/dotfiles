" use pathogen.vim for managing plugins (https://github.com/tpope/vim-pathogen)
execute pathogen#infect()
filetype plugin indent on

" don't need to be compatible with vi
set nocompatible
" supposedly this prevents security exploits, and I don't use it anyway
set modelines=0

" default indentation: 4 spaces
set ts=4 sts=4 sw=4 expandtab

""" basic options

set encoding=utf-8              " sane default file encoding
set scrolloff=3                 " minimum nuber of lines to keep above and below the cursor
set autoindent                  " use the indent of the current line for a new line
set showmode                    " show a message when in Insert, Replace, or Visual mode
set showcmd                     " show partial command in the last line on the screen
set hidden                      " buffer is hidden when abandoned (instead of unloaded)
set wildmenu                    " enhanced command line completion
set wildmode=list:longest       " list matches, and complete to the longest common string
set visualbell                  " use visual bell instead of beeping
set cursorline                  " highlight the screen line of the cursor
set ttyfast                     " indicates a fast terminal connection, should be smoother
set ruler                       " show the line and column of the cursor position
set backspace=indent,eol,start  " allow backspacing over these options in Insert mode
set laststatus=2                " always show the status line
set relativenumber              " show line number relative to cursor line
set undofile                    " save undo history to a file
set title                       " show title in console title bar
let mapleader = " "             " set the leader key to space (easier to type than backslash)

""" searching/moving

" use normal regex for search
nnoremap / /\v
vnoremap / /\v
set ignorecase                  " case insensitive search
set smartcase                   " any uppercase characters cause search to be case sensitive
set gdefault                    " use /g by default
set incsearch                   " show matches as you type
set showmatch                   " show matching brackets
set hlsearch                    " highlight search pattern matches
" get rid of search highlighting once I'm done with it
nnoremap <leader><space> :noh<cr>
" use Tab to jump between bracket pairs ([{}])
nnoremap <tab> %
vnoremap <tab> %

""" long line handling

set wrap                        " wrap long lines
set textwidth=96                " at 96 chars I can fit 2 windows side-by-side in tmux
set formatoptions=qrn1j         " text formatting options
" q - allows hard-wrapping comments with "gq"
" r - automatically insert the current comment leader after <Enter> in Insert mode
" n - recognize numbered lists
" 1 - don't break a line after a 1-letter word
" j - remove comment leader when joining lines

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

""" custom commands

" select the text that was just pasted, so I can do things to it
nnoremap <leader>v V`]
" search and replace the word under the cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>/
" open a new vertical split and switch to it
nnoremap <leader>w <C-w>v<C-w>l
" use ack in vim
nnoremap <leader>a :Ack

""" edit my vimrc

nmap <leader>ev :e $MYVIMRC<CR>
nmap <leader>sv :so $MYVIMRC<CR>

""" filetype styles

autocmd FileType ruby setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType vim setlocal ts=2 sts=2 sw=2 expandtab

""" syntax highlighting

syntax enable
" line numbers should be grey
hi LineNr       ctermfg=darkGrey
" this looks good for ruby, may have to change this for other languages
hi Normal       ctermfg=grey ctermbg=black
hi Operator     ctermfg=grey
hi Comment      ctermfg=darkGrey
hi Special      ctermfg=darkGrey
hi PreProc      ctermfg=darkGrey
hi Define       ctermfg=darkYellow
hi Conditional  ctermfg=darkYellow
hi Repeat       ctermfg=darkYellow
hi Statement    ctermfg=darkYellow
hi Exception    ctermfg=darkYellow
hi Keyword      ctermfg=darkYellow
hi Function     ctermfg=blue
hi Delimiter    ctermfg=blue
hi Include      ctermfg=darkBlue
hi String       ctermfg=darkCyan
hi Identifier   ctermfg=green
hi Constant     ctermfg=darkGreen
hi Number       ctermfg=darkGreen
hi Character    ctermfg=darkGreen
hi Float        ctermfg=darkGreen
hi Boolean      ctermfg=darkGreen
hi Type         ctermfg=darkGreen
hi Todo         ctermfg=darkRed ctermbg=black
hi Error        ctermfg=darkRed ctermbg=black
" colors for listchars
hi NonText      ctermfg=darkGrey
hi SpecialKey   ctermfg=darkGrey

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

" show hidden files in NERDTree
let NERDTreeShowHidden=1

" vim-slime with tmux
let g:slime_target="tmux"
" this will use the second pane of the window I am currently in
let g:slime_default_config = {"socket_name": "default", "target_pane": ":1.2"}

