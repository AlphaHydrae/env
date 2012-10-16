
" Plugins in ~/.vim/bundle
call pathogen#infect()

set number
set backspace=2
set autoindent
syntax on

let mapleader = ","

" NERD Tree
com GG NERDTree
let NERDTreeShowHidden=1

" delete key
imap  <Del>

" auto-completion
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby set tabstop=2|set shiftwidth=2|set expandtab
autocmd FileType js,javascript set tabstop=2|set shiftwidth=2|set expandtab
autocmd FileType haml,hamlc,sass set tabstop=2|set shiftwidth=2|set expandtab
autocmd FileType markdown set tabstop=2|set shiftwidth=2|set expandtab
au BufNewFile,BufRead *.hamlc set filetype=haml
au BufNewFile,BufRead *.god set filetype=ruby
au BufNewFile,BufRead *.md set filetype=markdown
set completeopt=longest,menuone

" Command-T
let g:CommandTMaxHeight=10

" mouse scrolling with mouseterm
if has("mouse")
  set mouse=a
endif
