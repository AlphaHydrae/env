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

Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'digitaltoad/vim-jade'
Plugin 'ervandew/supertab'
Plugin 'flazz/vim-colorschemes'
Plugin 'godlygeek/tabular'
Plugin 'groenewege/vim-less'
Plugin 'kchmck/vim-coffee-script'
Plugin 'leafgarland/typescript-vim'
Plugin 'majutsushi/tagbar'
Plugin 'rodjek/vim-puppet'
Plugin 'scrooloose/nerdtree'      " Tree explorer.
Plugin 'slim-template/vim-slim'
Plugin 'tpope/vim-fugitive'       " Git wrapper.
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-rails'
Plugin 'wavded/vim-stylus'
Plugin 'wincent/Command-T'        " Fast file navigation
Plugin 'Quramy/tsuquyomi'         " TypeScript plugin
Plugin 'Shougo/vimproc.vim'       " Interactive command execution
Plugin 'alvan/vim-closetag'       " Close XHTML tags
Plugin 'jiangmiao/auto-pairs'     " Close brackets, quotes, etc
Plugin 'tpope/vim-surround'       " Surround text with brackets, quotes, etc
Plugin 'pangloss/vim-javascript'  " JavaScript syntax
Plugin 'mxw/vim-jsx'              " JSX syntax (depends on pangloss/vim-javascript)
Plugin 'b4b4r07/vim-hcl'          " HashiCorp HCL syntax
Plugin 'asciidoc/vim-asciidoc'    " AsciiDoc syntax

" Vundle Help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

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
  \ 'json',
  \ 'python',
  \ 'ruby', 'rb=ruby',
  \ 'typescript', 'ts=typescript'
\ ]

" highlight JSX in JS files
let g:jsx_ext_required=0

" leader
let mapleader = ","

" NERD Tree
com TREE NERDTree
let NERDTreeShowHidden=1

" Command-T
com CTF CommandTFlush
let g:CommandTMaxHeight=10

" Pasting
com P set paste
com NP set nopaste

" Tabular
com MT Tab /|
com ASC Tab /:
com AEQ Tab /=

" Auto wrap current paragraph
nnoremap <leader>w {<S-v>}gq

" Auto-wrap git commit messages at 72 chars
autocmd Filetype gitcommit setlocal textwidth=72

" Open/Close with `Shift-T o` and `Shift-T c`.
nmap <S-T>o :NERDTree<Enter>
nmap <S-T>c :NERDTreeClose<Enter>

" delete key
imap  <Del>

" ctags
nnoremap t <C-]>
nnoremap <leader>T :CtrlPTag<cr>

" Tagbar
let g:tagbar_usearrows = 1
nnoremap <leader>b :TagbarToggle<CR>

" TypeScript (tsuquyomi)
com TD TsuDefinition
com TTD TsuTypeDefinition
com TSI TsuImport
let g:tsuquyomi_completion_detail = 1
let g:tsuquyomi_single_quote_import = 1
let g:tsuquyomi_shortest_import_path = 1
au BufNewFile,BufRead *.ts,*.tsx nnoremap <leader>d :TsuDefinition<cr>
au BufNewFile,BufRead *.ts,*.tsx nnoremap <leader>D :TsuTypeDefinition<cr>

" auto-completion
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
au BufNewFile,BufRead *.adoc set filetype=asciidoc
au BufNewFile,BufRead *.ejs set filetype=javascript
au BufNewFile,BufRead *.hamlc set filetype=haml
au BufNewFile,BufRead *.god set filetype=ruby
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.god set filetype=ruby
au BufNewFile,BufRead *.god.j2 set filetype=ruby
au BufNewFile,BufRead *.raml set filetype=yaml
au BufNewFile,BufRead *.slm set filetype=slim
au BufNewFile,BufRead *.yml.j2 set filetype=yaml
au BufNewFile,BufRead {config.ru,Capfile,Gemfile,Guardfile,Puppetfile,Rakefile,Thorfile,Vagrantfile} set ft=ruby
au BufNewFile,BufRead {.nycrc} set filetype=json
set completeopt=longest,menuone

" mouse scrolling with mouseterm
if has("mouse")
  set mouse=a
endif

" asciidoc list formatting
autocmd BufRead,BufNewFile *.adoc,*.asciidoc
        \ setlocal autoindent expandtab tabstop=8 softtabstop=2 shiftwidth=2 filetype=asciidoc
        \ textwidth=80 wrap formatoptions=tcqn
        \ formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\\|^\\s*<\\d\\+>\\s\\+\\\\|^\\s*[a-zA-Z.]\\.\\s\\+\\\\|^\\s*[ivxIVX]\\+\\.\\s\\+
        \ comments=s1:/*,ex:*/,://,b:#,:%,:XCOMM,fb:-,fb:*,fb:+,fb:.,fb:>
