" use pathogen.vim for managing plugins (https://github.com/tpope/vim-pathogen)
execute pathogen#infect()

set nocompatible              " Use vim defaults
"set ls=2                      " Always show status line
set showcmd                   " Show incomplete commands
set scrolloff=3               " Keep 3 lines when scrolling
set ruler                     " Show the cursor position all the time
set title                     " Show title in console title bar
set hid                       " Change buffer without saving
set showmatch                 " Show matching bracets

" default indentation: 4 spaces
set ts=4 sts=4 sw=4 expandtab

" show whitespace, using the same symbols as TextMate for tabstops and EOLs
"set list
set listchars=tab:▸\ ,eol:¬

" wrap text at 96 chars (so I can fit 2 windows side-by-side in tmux)
set wrap
set textwidth=96

" searching
set hlsearch                  " Highlight searches
set incsearch                 " Do incremental searching

" set the leader key to space (easier to type than backslash)
let mapleader = " "

" leader commands

" select the text that was just pasted, so I can do things to it
nnoremap <leader>v V`]
" get rid of annoying highlighting once I'm done with it
nnoremap <leader><space> :noh<cr>

" only if compiled with support for autocommands
if has("autocmd")
  " enable file type detection
  " also loads indent files, to automatically to language-dependent indenting
  filetype plugin indent on

  " customizations based on accepted styles (mostly)
  autocmd FileType ruby setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType vim setlocal ts=2 sts=2 sw=2 expandtab

  " strip trailing whitespace before file write
  autocmd BufWritePre     * :call StripTrailingWhitespace()
endif

" syntax highlighting
syntax enable
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

" show hidden files in NERDTree
let NERDTreeShowHidden=1

" to search and replace the word under the cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

