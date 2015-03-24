
" Plugins in ~/.vim/bundle
execute pathogen#infect()

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

syntax on

" highlight alt-space
highlight BadSpaces term=standout ctermbg=yellow guibg=yellow
call matchadd('BadSpaces', ' ')

" hilight tabs and trailing spaces
set listchars=tab:→\ ,trail:•
set list

let mapleader = ","

" NERD Tree
com TREE NERDTree
com CTF CommandTFlush
com P set paste
com NP set nopaste
let NERDTreeShowHidden=1
" Open/Close with `Shift-T o` and `Shift-T c`.
nmap <S-T>o :NERDTree<Enter>
nmap <S-T>c :NERDTreeClose<Enter>

" delete key
imap  <Del>

" auto-completion
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
au BufNewFile,BufRead *.hamlc set filetype=haml
au BufNewFile,BufRead *.god set filetype=ruby
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.god set filetype=ruby
au BufNewFile,BufRead *.god.j2 set filetype=ruby
au BufNewFile,BufRead *.raml set filetype=yaml
au BufNewFile,BufRead {config.ru,Capfile,Gemfile,Guardfile,Puppetfile,Rakefile,Thorfile,Vagrantfile} set ft=ruby
set completeopt=longest,menuone

" Command-T
let g:CommandTMaxHeight=10

" mouse scrolling with mouseterm
if has("mouse")
  set mouse=a
endif
