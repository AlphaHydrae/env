# Dotfiles
symlink dot_files.except('.gitmodules', '.zshlocal', '.bash_profile'), overwrite: true, backup: false
copy('.zshlocal').once
copy('.bash_profile').once

# HTTPie
from '.httpie' do
  copy('config.json').to('~/.httpie').once
end

from '.config/zellij' do
  symlink('config.kdl').to('.config/zellij')
end

# Visual Studio Code
vscode_dir = File.expand_path(File.join('~', 'Library', 'Application Support', 'Code', 'User'))
if File.directory? vscode_dir
  from 'vscode' do
    symlink('keybindings.json', overwrite: true).to(vscode_dir)
    symlink('settings.json', overwrite: true).to(vscode_dir)
  end
end

# Private configuration
private_config_dir = ENV['PRIVATE_CONFIG_DIR']
raise 'Environment variable $PRIVATE_CONFIG_DIR is required' unless private_config_dir
from private_config_dir do
  symlink dot_files.except('.secrets', '.gitenv.private.rb')
  copy('.secrets').once

  from '.config/fenix' do
    symlink('config.yml').to('.config/fenix')
  end

  from '.config/infrastructure' do
    symlink('config.yml').to('.config/infrastructure')
  end

  from '.config/rclone' do
    symlink('rclone.conf').to('.config/rclone')
  end

  from '.config/update-asdf-tools' do
    symlink('update-asdf-tools.conf').to('.config/update-asdf-tools')
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
