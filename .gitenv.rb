
repo "~/Projects/env" do
  symlink dot_files
  symlink('prompt_adam2_setup').to('/opt/local/share/zsh/5.0.2/functions')
end

from "~/Safebox/Config" do
  symlink dot_files
  symlink('config').from('.ssh').to('.ssh')
  symlink('settings.xml').from('.m2').to('.m2') if File.directory?(File.expand_path('~/.m2'))
end
