
symlink dot_files.except('.zshconfig', '.bash_profile')
copy('.zshconfig').once
copy('.bash_profile').once

if File.directory? File.expand_path("~/Safebox/Config")
  from "~/Safebox/Config" do
    symlink dot_files.except('.env')
    copy('.env').once
    symlink('config').from('.ssh').to('.ssh')
    symlink('settings.xml').from('.m2').to('.m2') if File.directory?(File.expand_path('~/.m2'))
  end
end
