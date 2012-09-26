call pathogen#infect()

set number
set backspace=2
set autoindent
syntax on
com GG NERDTree

let mapleader = ","

" delete and backspace
set t_kD=
set t_kb=

" auto-completion
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby set tabstop=2|set shiftwidth=2|set expandtab
autocmd FileType js,javascript set tabstop=2|set shiftwidth=2|set expandtab
autocmd FileType haml,hamlc,sass set tabstop=2|set shiftwidth=2|set expandtab
au BufNewFile,BufRead *.hamlc set filetype=haml
au BufNewFile,BufRead *.god set filetype=ruby
set completeopt=longest,menuone

" command-t
let g:CommandTMaxHeight=10

" mouse scrolling with mouseterm
" if has("mouse")
set mouse=a
" endif
