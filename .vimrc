set encoding=utf-8

set number
set backspace=2
set autoindent

set noswapfile       " Disable .swp file creation.
set nobackup         " Don't make a backup before overwriting a file.
set nowritebackup    " And again.

set tabstop=2        " Global tab width.
set shiftwidth=2     " And again, related.
set expandtab        " Use spaces instead of tabs.

" ignores
set wildignore+=dist/**
set wildignore+=bower_components/**
set wildignore+=node_modules/**
set wildignore+=tmp/**
set wildignore+=vendor/**

" add the hyphen as a keyword character
set iskeyword+=-

" Vundle
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'digitaltoad/vim-jade'
Plugin 'ervandew/supertab'
Plugin 'flazz/vim-colorschemes'
Plugin 'godlygeek/tabular'
Plugin 'groenewege/vim-less'
Plugin 'kchmck/vim-coffee-script'
Plugin 'majutsushi/tagbar'
Plugin 'rodjek/vim-puppet'
Plugin 'scrooloose/nerdtree'
Plugin 'slim-template/vim-slim'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-rails'
Plugin 'wavded/vim-stylus'
Plugin 'wincent/Command-T'

call vundle#end()
filetype plugin indent on

syntax on

" highlight alt-space
highlight BadSpaces term=standout ctermbg=yellow guibg=yellow
call matchadd('BadSpaces', ' ')

" hilight tabs and trailing spaces
set listchars=tab:→\ ,trail:•
set list

" highlight fenced code blocks in markdown
let g:markdown_fenced_languages = [
  \ 'css', 'less', 'stylus',
  \ 'html', 'slim',
  \ 'javascript', 'js=javascript',
  \ 'python',
  \ 'ruby', 'rb=ruby'
\ ]

" leader
let mapleader = ","

" NERD Tree
com TREE NERDTree
let NERDTreeShowHidden=1

" Command-T
com CTF CommandTFlush

" Pasting
com P set paste
com NP set nopaste

" Tabular
com MT Tab /|

" Open/Close with `Shift-T o` and `Shift-T c`.
nmap <S-T>o :NERDTree<Enter>
nmap <S-T>c :NERDTreeClose<Enter>

" delete key
imap  <Del>

" Command-T
let g:CommandTMaxHeight=10

" ctags
nnoremap t <C-]>
nnoremap <leader>T :CtrlPTag<cr>

" Tagbar
let g:tagbar_usearrows = 1
nnoremap <leader>b :TagbarToggle<CR>

" auto-completion
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
au BufNewFile,BufRead *.ejs set filetype=javascript
au BufNewFile,BufRead *.hamlc set filetype=haml
au BufNewFile,BufRead *.god set filetype=ruby
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.god set filetype=ruby
au BufNewFile,BufRead *.god.j2 set filetype=ruby
au BufNewFile,BufRead *.raml set filetype=yaml
au BufNewFile,BufRead {config.ru,Capfile,Gemfile,Guardfile,Puppetfile,Rakefile,Thorfile,Vagrantfile} set ft=ruby
set completeopt=longest,menuone

" mouse scrolling with mouseterm
if has("mouse")
  set mouse=a
endif
