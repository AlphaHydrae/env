# encoding: utf-8
require 'dotenv'

hostname = `hostname`.strip.sub(/\.local/, '').downcase
Dotenv.load! File.expand_path("~/.env.d/backups.#{hostname}")

#
# $ backup perform -t installation [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://meskyanichi.github.io/backup
#
Model.new(:installation, 'Machine configuration') do

  before do

    FileUtils.mkdir_p "/tmp/installation"
    FileUtils.chmod 0700, "/tmp/installation"

    # list installed ports
    system "/opt/local/bin/port -qv installed > /tmp/installation/macports.txt" if File.executable? "/opt/local/bin/port"

    # list applications
    system "ls /Applications > /tmp/installation/apps.txt"

    # list home directory
    system "ls -la ~ > /tmp/installation/home.txt"
  end

  after do
    FileUtils.remove_entry_secure "/tmp/installation"
  end

  split_into_chunks_of 100

  # System config, daemons, apps
  archive :system do |a|

    a.root "/tmp/installation"
    a.add "apps.txt"

    a.add "/etc/bashrc"
    a.add "/etc/hosts"
    a.add "/etc/profile"
    a.add "/etc/shells"
    a.add "/etc/sshd_config"
    a.add "/etc/zshenv"

    a.add "/Library/LaunchAgents"
    a.add "/Library/LaunchDaemons"
  end

  # MacPorts
  if File.directory? "/opt/local"

    archive :macports do |a|

      a.root "/tmp/installation"
      a.add "macports.txt"

      a.add "/opt/local/etc"

      %w(DB_CONFIG.example slapd.conf.default slapd.ldif slapd.ldif.default).each do |f|
        a.exclude File.join "/opt/local/etc/openldap", f
      end
    end
  end

  # User backup config, daemons, home
  archive :user do |a|
    a.root File.expand_path("~")
    a.add "Library/LaunchAgents"
    a.add "/tmp/installation/home.txt"
  end

  compress_with Gzip

  encrypt_with GPG do |encryption|

    encryption.keys = [ ENV['MACHINE_BACKUP_GPG_KEY'] ].inject({}) do |memo,key|
      memo[key] = `gpg -a --export "#{key}"`
      memo
    end

    encryption.recipients = ENV['MACHINE_BACKUP_GPG_KEY']
  end

  store_with S3 do |s3|
    s3.access_key_id     = ENV['MACHINE_BACKUP_S3_ACCESS_KEY_ID'].dup
    s3.secret_access_key = ENV['MACHINE_BACKUP_S3_SECRET_ACCESS_KEY'].dup
    s3.region            = ENV['MACHINE_BACKUP_S3_REGION'].dup
    s3.bucket            = ENV['MACHINE_BACKUP_S3_BUCKET'].dup
    s3.path              = ENV['MACHINE_BACKUP_S3_PATH'].dup
    s3.encryption        = :aes256
  end

  store_with Local do |local|
    local.path = File.expand_path("~/Transient/Backups")
    local.keep = 10
  end
end
