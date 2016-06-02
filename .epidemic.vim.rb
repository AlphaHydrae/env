
add "git://github.com/tpope/vim-fugitive.git"
add "git://github.com/tpope/vim-rails.git"
add "git://github.com/ervandew/supertab.git"
add "git://github.com/scrooloose/nerdtree.git"
add "git://github.com/tpope/vim-markdown.git"
add "git://github.com/rodjek/vim-puppet.git"
add "git://github.com/flazz/vim-colorschemes.git"
add "git://github.com/godlygeek/tabular.git"
add "git://github.com/kchmck/vim-coffee-script.git"
add "git://github.com/wavded/vim-stylus.git"
add "git://github.com/slim-template/vim-slim.git"
add "git://github.com/digitaltoad/vim-jade.git"
add "git://github.com/groenewege/vim-less.git"
add "git://github.com/ctrlpvim/ctrlp.vim.git"
add "git://github.com/majutsushi/tagbar.git"

add "git://github.com/wincent/Command-T.git" do
  Dir.chdir "ruby/command-t"
  raise "$VIM_RUBY must be set when RVM is enabled" if Which.which("rvm") and !ENV['VIM_RUBY']
  bin = ENV['VIM_RUBY'] || 'ruby'
  raise "Could not build makefile" unless system "#{bin} extconf.rb"
  raise "Could not make clean" unless system "make clean"
  raise "Could not make" unless system "make"
end
