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

" indenting
set smartindent               " Smart indent
set autoindent
set nocindent

set wrap

" searching
set hlsearch                  " Highlight searches
set incsearch                 " Do incremental searching

" only if compiled with support for autocommands
if has("autocmd")
  " enable file type detection
  " also loads indent files, to automatically to language-dependent
  " indenting
  filetype plugin indent on

  " customizations based on accepted styles (mostly)
  autocmd FileType ruby setlocal sw=2 ts=2 sts=2 expandtab
  autocmd FileType vim setlocal sw=2 ts=2 sts=2 expandtab
endif

syntax enable
"set background=dark
"hi Normal ctermfg=grey ctermbg=darkgrey
hi PreProc ctermfg=magenta
hi Statement ctermfg=darkYellow
hi Type ctermfg=blue
hi Function ctermfg=blue
hi Identifier ctermfg=darkBlue
hi Special ctermfg=darkCyan
hi Constant ctermfg=darkCyan
hi Comment ctermfg=darkGreen
au BufRead,BufNewFile *.rb hi rubySymbol ctermfg=green

" remove trailing whitespace
function! TrimWhiteSpace()
  %s/\s\+$//e
endfunction

autocmd FileWritePre    * :call TrimWhiteSpace()
autocmd FileAppendPre   * :call TrimWhiteSpace()
autocmd FilterWritePre  * :call TrimWhiteSpace()
autocmd BufWritePre     * :call TrimWhiteSpace()

" show hidden files in NERDTree
let NERDTreeShowHidden=1

" to search and replace the word under the cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

" use the same symbols as TextMate for tabstops and EOLs
" (http://vimcasts.org/episodes/show-invisibles/)
set listchars=tab:▸\ ,eol:¬
