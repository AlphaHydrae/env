
zsh_version = Dir.entries('/opt/local/share/zsh').select{ |e| e.match /\A\d+\.\d+\.\d+\Z/ }.sort.last
raise "Could not detect ZSH version" unless zsh_version

repo "~/Projects/env" do
  symlink dot_files.except('.zshconfig', '.bash_profile')
  copy('.zshconfig').once
  copy('.bash_profile').once
  copy('prompt_adam2_setup').to("/opt/local/share/zsh/#{zsh_version}/functions")
end

from "~/Safebox/Config" do
  symlink dot_files.except('.env')
  copy('.env').once
  symlink('config').from('.ssh').to('.ssh')
  symlink('settings.xml').from('.m2').to('.m2') if File.directory?(File.expand_path('~/.m2'))
end
