" Plugins
"
" Plugins are currently managed with git submodules (which kinda suck but ¯\_(ツ)_/¯).
"
" TODO: these are painful, I should make them into scripts
"
" ADD a plugin:
"  * `git submodule add [-b branch] https://github.com/<user>/<project-name>.git .vim/pack/mikrostew/start/<project-name>`
"  * (commit the changes)
"  * then update plugins on another computer
"    - `git submodule init`
"    - `git submodule update`
"
" UPDATE plugins:
"  * `git submodule update --remote`
"  * (commit the changes)
"
" REMOVE a plugin (from https://stackoverflow.com/a/1260982)
"  (TODO: maybe a better way: https://shapeshed.com/vim-packages/)
"  * Delete the relevant section from the .gitmodules file
"  * Stage the .gitmodules changes: `git add .gitmodules`
"  * Delete the relevant section from .git/config
"  * Remove the submodule files from the working tree and index: `git rm --cached path_to_submodule` (no trailing slash)
"  * Remove the submodule's .git directory: `rm -rf .git/modules/path_to_submodule` (trailing slash ok)
"  * Commit the changes: `git commit -m 'removed submodule <name>'`
"  * Delete the now untracked submodule files: `rm -rf path_to_submodule`
"  * (after deleting a plugin, will have to manually remove the plugin dir on other machines)
"
" CHANGE URL of a plugin (from https://stackoverflow.com/a/66072686)
"  * `git submodule set-url path/to/submodule <new URL>`
"  * (commit the changes)
"  * (Note: have to run this on other machines that check out this repo - is there a better way?)

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
set laststatus=2                " always show the status line, and one line below
" if exists('&relativenumber')
"   set relativenumber            " show line number relative to cursor line
" endif
set number                      " show line numbers
set title                       " show title in console title bar
let mapleader = " "             " set the leader key to space (easier to type than backslash)
" automatically load file changes when running an external command in vim
" https://unix.stackexchange.com/a/383044
set autoread

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
" Grep command: grep CWD, and open results in a quickfix buffer w/ links and highlight the matches
" (from https://chase-seibert.github.io/blog/2013/09/21/vim-grep-under-cursor.html)
command! -nargs=+ Grep execute 'silent grep! -n -I -r --exclude-dir node_modules --exclude-dir .git --exclude-dir .bundle . -e <args>' | copen | execute 'silent /<args>'
" Grep for the word under the cursor
":nmap <leader>g :Grep <c-r>=expand("<cword>")<cr><cr>

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
"autocmd FocusLost * :wa
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
" include dashes in autocomplete
set iskeyword+=\-

""" misc commands

" select the text that was just pasted, so I can do things to it
nnoremap <leader>v V`]
" search and replace the word under the cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>/
" open split (with '|' or '-'), then open file browser
nnoremap <leader>\| <C-w>v<C-w>l:e.<CR>
nnoremap <leader>- <C-w>s<C-w>j:e.<CR>
" set the currently file to executable
" (using silent, so I don't have to press Enter after the command)
nnoremap <leader>x :silent !chmod +x "%"<CR>

""" edit and re-source my vimrc

nmap <leader>ev :e $MYVIMRC<CR>
nmap <leader>sv :so $MYVIMRC<CR>

""" filetype styles

autocmd FileType ruby setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType vim setlocal ts=2 sts=2 sw=2 expandtab

""" syntax highlighting

" syntax highlighting, with a nice colorscheme
syntax enable
" dark
colorscheme wombat
" light
" colorscheme delek

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

" set custom highlighting based on the shebang
function! SetCustomSyntaxHighlighting()
  " (see https://stackoverflow.com/a/2577449)
  if did_filetype()   " don't check if filetype is already set
      finish
  endif
  " badash
  if getline(1) =~ '^#!/usr/bin/env badash'
      setfiletype bash
  endif
endfunction

""" plugins

" netrw (built-in)
" hide these file extensions (from https://stackoverflow.com/a/21020164/)
let g:netrw_list_hide= '.*\.swp$,\~$,\.orig$'

" airline (https://github.com/vim-airline/vim-airline)
"let g:airline_section_b = ''  " git branch info
let g:airline_section_y = ''  " this file encoding

" ALE (async lint engine) settings
" (https://github.com/dense-analysis/ale)
" custom stuff (adapted from https://davidtranscend.com/blog/configure-eslint-prettier-vim/)
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
highlight ALEErrorSign ctermbg=NONE ctermfg=red guibg=NONE guifg=red
highlight ALEWarningSign ctermbg=NONE ctermfg=yellow guibg=NONE guifg=yellow
" auto-fix errors on save
let g:ale_fixers = {
\   'javascript': ['eslint'],
\   'typescript': ['eslint'],
\}
let g:ale_fix_on_save = 1
" show ALE errors and warnings in the status line
let g:airline#extensions#ale#enabled = 1
" jump to next error
nnoremap <leader>e :ALENext -wrap -error<CR>
" jump to next warning
nnoremap <leader>w :ALENext -wrap -warning<CR>


" CtrlP
" command mapping
let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlP'
" set the local working directory to project root
let g:ctrlp_working_path_mode = 'ra'
" ignore these directories
set wildignore+=*/vendor/**
set wildignore+=*/target/**

" rust.vim
" automatically format when saving a buffer
let g:rustfmt_autosave = 1

" font
" (install IBM plex font from https://github.com/IBM/plex)
if has("mac") || has("macunix")
  set guifont=IBM\ Plex\ Mono:h14,Source\ Code\ Pro:h15,Menlo:h15
endif

" Open markdown files with Chrome (on OSX)
" (adapted from https://stackoverflow.com/a/14718908 and https://stackoverflow.com/a/21187692)
" and using Markdown Preview Plus (https://chrome.google.com/webstore/detail/markdown-preview-plus/febilkbfcbhebfnokafefeacimjdckgl)
autocmd BufEnter *.md exe 'noremap <leader>m :!open -a "Google Chrome" %:p<CR>'

" custom syntax highlighting
autocmd BufEnter * :call SetCustomSyntaxHighlighting()


" yank the full path to the currently open file
" (https://stackoverflow.com/a/17096082)
nnoremap <leader>yf :let @+ = expand("%:p")<CR>


"""""""""""""""
" coc.nvim
"""""""""""""""
" from https://github.com/neoclide/coc.nvim#example-vim-configuration

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
"set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
"nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
"nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
"nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
"nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
"nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
"nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
"nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
"nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" install these CoC extensions if they are missing
let g:coc_global_extensions = [
  \ 'coc-actions',
  \ 'coc-css',
  \ 'coc-ember',
  \ 'coc-highlight',
  \ 'coc-html',
  \ 'coc-json',
  \ 'coc-rust-analyzer',
  \ 'coc-tsserver',
  \ 'coc-vimlsp'
\ ]

"""""""""""""""
" end of coc.nvim
"""""""""""""""

" project-specific configuration
" using `set exrc` seems like a bad idea: https://vi.stackexchange.com/questions/5055/why-is-set-exrc-dangerous
" so I'm going to try a suggestion from a comment here: https://vim.fandom.com/wiki/Project_specific_settings
function! SetupEnvironment()
  let l:path = expand('%:p')
  if l:path =~ '/Users/mikrostew/src/automaticowl.net'
    silent! so .vimlocal
  elseif l:path =~ '/Users/mistewar/src/li/blog'
    silent! so .vimlocal
  endif
endfunction
autocmd! BufReadPost,BufNewFile * call SetupEnvironment()

" TODO - use yaml-fromat to change things, in .vimlocal
" https://superuser.com/questions/1018808/how-do-you-run-a-vim-command-that-is-the-text-inside-a-buffer
