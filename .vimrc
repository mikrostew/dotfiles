set nocompatible              " Use vim defaults
"set ls=2                      " Always show status line
set showcmd                   " Show incomplete commands
set scrolloff=3               " Keep 3 lines when scrolling
set ruler                     " Show the cursor position all the time
set title                     " Show title in console title bar
set hid                       " Change buffer without saving
set showmatch                 " Show matching bracets

" spaces, no tabs
set ts=4                      " Numbers of spaces of tab character
set sw=4                      " Numbers of spaces to (auto)indent
set et                        " Tabs are converted to spaces, use only when required
set sts=4                     " Soft tab stop

" indenting
set smartindent               " Smart indent
set autoindent
set nocindent

set wrap

" searching
set hlsearch                  " Highlight searches
set incsearch                 " Do incremental searching

"if has("autocmd")
"au FileType cpp,c,java,sh,pl,php,python,ruby set autoindent
"au FileType cpp,c,java,sh,pl,php,py,rb set smartindent
"au FileType cpp,c,java,sh,pl,php set cindent
"au BufRead *.py set cinwords=if,elif,else,for,while,try,except,finally,def,class
"au BufRead *.rb set cinwords=if,elsif,else,unless,for,while,begin,rescue,def,class,module
"au BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
"au BufRead *.rb set smartindent cinwords=if,elsif,else,unless,for,while,begin,rescue,def,class,module
"endif

filetype plugin indent on
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

" only indent 2 spaces for ruby files
autocmd FileType ruby setlocal sw=2 ts=2 sts=2

" to search and replace the word under the cursor
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

" use the same symbols as TextMate for tabstops and EOLs
" (http://vimcasts.org/episodes/show-invisibles/)
set listchars=tab:▸\ ,eol:¬
