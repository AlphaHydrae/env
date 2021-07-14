symlink dot_files.except('.zshlocal', '.bash_profile'), overwrite: true, backup: false
copy('.zshlocal').once
copy('.bash_profile').once

from '.httpie' do
  copy('config.json').to('~/.httpie').once
end

from 'oh-my-zsh' do
  symlink(all_files).to('.oh-my-zsh/custom')
end

vscode_dir = File.expand_path(File.join('~', 'Library', 'Application Support', 'Code', 'User'))
if File.directory? vscode_dir
  from 'vscode' do
    symlink('keybindings.json', overwrite: true).to(vscode_dir)
    symlink('settings.json', overwrite: true).to(vscode_dir)
  end
end

zsh_old_homebrew_path = '/usr/local/Cellar/zsh'
zsh_homebrew_path = '/opt/homebrew/Cellar/zsh'
zsh_homebrew_path = zsh_old_homebrew_path if File.directory? zsh_old_homebrew_path
if File.directory? zsh_homebrew_path
  zsh_version = Dir.entries(zsh_homebrew_path).select{ |e| e.match(/\A\d+\.\d+(?:\.\d+)?(?:_\d+)?\Z/) }.sort.last
  raise 'Could not detect ZSH version' unless zsh_version
  copy('prompt_adam2_setup', overwrite: true).to File.join(zsh_homebrew_path, zsh_version, 'share', 'zsh', 'functions')
end

private_config_dir = ENV['PRIVATE_CONFIG']
if private_config_dir && File.directory?(File.expand_path(private_config_dir))
  from private_config_dir do
    symlink dot_files.except('.env')
    copy('.env').once
    symlink('config').from('.ssh').to('.ssh')
  end
end
