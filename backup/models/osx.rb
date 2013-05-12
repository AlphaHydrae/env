# encoding: utf-8
require 'dotenv'
require 'fileutils'

hostname = `hostname`.strip.sub(/\.local/, '').downcase
Dotenv.load! File.expand_path("~/.env.d/backups.#{hostname}")

##
# Backup Generated: osx
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t osx [-c <path_to_configuration_file>]
#
Backup::Model.new(:osx, 'OS X Machine Configuration') do

  before do |model|

    FileUtils.mkdir_p "/tmp/installation"
    FileUtils.chmod 0700, "/tmp/installation"

    # list installed ports
    system "/opt/local/bin/port -qv installed > /tmp/installation/macports.txt" if File.executable? "/opt/local/bin/port"

    # list applications
    system "ls /Applications > /tmp/installation/apps.txt"

    # list home directory
    system "ls -la ~ > /tmp/installation/home.txt"
  end

  after do |model|
    FileUtils.remove_entry_secure "/tmp/installation"
  end

  split_into_chunks_of 250

  # System config, daemons, apps
  archive :system do |a|
    a.use_sudo
    a.add "/etc/bashrc"
    a.add "/etc/hosts"
    a.add "/etc/profile"
    a.add "/etc/shells"
    a.add "/etc/sshd_config"
    a.add "/etc/zshenv"
    a.add "/Library/LaunchAgents"
    a.add "/Library/LaunchDaemons"
    a.add "/tmp/installation/apps.txt"
  end

  # MacPorts
  if File.directory? "/opt/local"

    archive :macports do |a|

      a.use_sudo
      a.add "/opt/local/etc"
      a.add "/tmp/installation/macports.txt"

      # PostgreSQL
      if `which psql`.match /\/opt\/local/
        dir = `echo "select setting from pg_settings where name = 'data_directory';" | psql -t -Upostgres`.strip
        %w(pg_hba pg_ident postgresql).each do |name|
          a.add File.join(dir, "#{name}.conf")
        end
      end
    end
  end

  # User daemons, home
  archive :user do |a|
    a.add File.expand_path('~/Library/LaunchAgents')
    a.add "/tmp/installation/home.txt"
  end

  # Backup config & state
  archive :backup do |a|
    a.root File.expand_path("~")
    a.add File.expand_path("~/Backup/config.rb")
    a.add File.expand_path("~/Backup/data")
    a.add File.expand_path("~/Backup/models")
  end

  compress_with Gzip

  encrypt_with GPG do |encryption|
    encryption.mode = :symmetric
    encryption.passphrase = ENV['BACKUP_PASSWORD'].dup
  end

  store_with S3 do |s3|
    s3.access_key_id     = ENV['BACKUP_S3_ACCESS_KEY_ID'].dup
    s3.secret_access_key = ENV['BACKUP_S3_SECRET_ACCESS_KEY'].dup
    s3.region            = ENV['BACKUP_S3_REGION'].dup
    s3.bucket            = ENV['BACKUP_S3_BUCKET'].dup
    s3.path              = ENV['BACKUP_S3_PATH'].dup
    s3.keep              = 100
  end

  store_with Local do |local|
    local.path = File.expand_path("~/Transient/Backups")
    local.keep = 25
  end
end
