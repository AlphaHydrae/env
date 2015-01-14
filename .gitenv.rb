
zsh_entries = Dir.entries([ '/opt/local/share/zsh', '/usr/share/zsh' ].find{ |path| File.directory? path })
zsh_version = zsh_entries.select{ |e| e.match /\A\d+\.\d+\.\d+\Z/ }.sort.last
raise "Could not detect ZSH version" unless zsh_version

repo "~/Projects/env" do
  symlink dot_files.except('.zshconfig', '.bash_profile')
  copy('.zshconfig').once
  copy('.bash_profile').once
  copy('prompt_adam2_setup').to("/opt/local/share/zsh/#{zsh_version}/functions")
end

if File.directory? File.expand_path("~/Safebox/Config")
  from "~/Safebox/Config" do
    symlink dot_files.except('.env')
    copy('.env').once
    symlink('config').from('.ssh').to('.ssh')
    symlink('settings.xml').from('.m2').to('.m2') if File.directory?(File.expand_path('~/.m2'))
  end
end
