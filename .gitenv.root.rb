
zsh_path = [ '/opt/local/share/zsh', '/usr/local/Cellar/zsh', '/usr/share/zsh' ].find{ |path| File.directory? path }
zsh_version = Dir.entries(zsh_path).select{ |e| e.match /\A\d+\.\d+(?:\.\d+)?\Z/ }.sort.last
raise "Could not detect ZSH version" unless zsh_version

copy('prompt_adam2_setup').to File.join(zsh_path, zsh_version, "functions")
