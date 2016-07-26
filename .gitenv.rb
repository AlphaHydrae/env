
symlink dot_files.except('.zshconfig', '.bash_profile')
copy('.zshconfig').once
copy('.bash_profile').once

from '.httpie' do
  copy('config.json').to('~/.httpie').once
end

from 'launchd' do
  symlink('com.alphahydrae.android.plist').to('~/Library/LaunchAgents')
end

zsh_homebrew_path = '/usr/local/Cellar/zsh'
if File.directory? zsh_homebrew_path
  zsh_version = Dir.entries(zsh_homebrew_path).select{ |e| e.match /\A\d+\.\d+(?:\.\d+)?\Z/ }.sort.last
  raise "Could not detect ZSH version" unless zsh_version
  copy('prompt_adam2_setup', backup: true).to File.join(zsh_path, zsh_version, "functions")
end

if File.directory? File.expand_path("~/Safebox/Config")
  from "~/Safebox/Config" do
    symlink dot_files.except('.env')
    copy('.env').once
    symlink('config').from('.ssh').to('.ssh')
    symlink('settings.xml').from('.m2').to('.m2') if File.directory?(File.expand_path('~/.m2'))
  end
end
