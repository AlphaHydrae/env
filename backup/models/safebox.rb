# encoding: utf-8

#
# $ backup perform -t safebox
#
# For more information about Backup's components, see the documentation at:
# http://meskyanichi.github.io/backup
#
Model.new(:safebox, 'Sync safebox') do

  sync_with RSync::Local do |rsync|
    rsync.path     = "~/Backup/local/Safebox"
    rsync.mirror   = true

    rsync.directories do |directory|

      home = File.expand_path '~'
      Dir.entries(File.join(home, "Safebox")).reject{ |e| e.match /^\./ }.each do |e|
        directory.add File.join(home, "Safebox", e)
      end
    end
  end
end
