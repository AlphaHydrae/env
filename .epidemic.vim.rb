
install "git://github.com/tpope/vim-fugitive.git"
install "git://github.com/tpope/vim-rails.git"
install "git://github.com/ervandew/supertab.git"
install "git://github.com/scrooloose/nerdtree.git"

install "git://github.com/wincent/Command-T.git" do
  Dir.chdir "ruby/command-t"
  raise "$VIM_RUBY must be set when RVM is enabled" if Which.which("rvm") and !ENV['VIM_RUBY']
  bin = ENV['VIM_RUBY'] || 'ruby'
  raise "Could not build makefile" unless system "#{bin} extconf.rb"
  raise "Could not make" unless system "make"
end
