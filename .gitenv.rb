# Dotfiles
symlink dot_files.except('.gitmodules', '.zshlocal', '.bash_profile'), overwrite: true, backup: false
copy('.zshlocal').once
copy('.bash_profile').once

# HTTPie
from '.httpie' do
  copy('config.json').to('~/.httpie').once
end

# Visual Studio Code
vscode_dir = File.expand_path(File.join('~', 'Library', 'Application Support', 'Code', 'User'))
if File.directory? vscode_dir
  from 'vscode' do
    symlink('keybindings.json', overwrite: true).to(vscode_dir)
    symlink('settings.json', overwrite: true).to(vscode_dir)
  end
end

# ZSH
zsh_old_homebrew_path = '/usr/local/Cellar/zsh'
zsh_homebrew_path = '/opt/homebrew/Cellar/zsh'
zsh_homebrew_path = zsh_old_homebrew_path if File.directory? zsh_old_homebrew_path
if File.directory? zsh_homebrew_path
  zsh_version = Dir.entries(zsh_homebrew_path).select{ |e| e.match(/\A\d+\.\d+(?:\.\d+)?(?:_\d+)?\Z/) }.sort.last
  raise 'Could not detect ZSH version' unless zsh_version
  copy('prompt_adam2_setup', overwrite: true).to File.join(zsh_homebrew_path, zsh_version, 'share', 'zsh', 'functions')
end

# Private configuration
private_config_dir = ENV['PRIVATE_CONFIG_DIR']
raise 'Environment variable $PRIVATE_CONFIG_DIR is required' unless private_config_dir
from private_config_dir do
  symlink dot_files.except('.secrets', '.gitenv.private.rb')
  copy('.secrets').once

  from '.config' do
    symlink('rclone.conf').to('.config/rclone')
  end

  from '.m2' do
    symlink('settings.xml').to('.m2')
  end

  from '.ssh' do
    symlink('config').to('.ssh')
    symlink('config.sync.d').to('.ssh')
  end
end

# Further private configuration
include File.join(private_config_dir, '.gitenv.private.rb')
