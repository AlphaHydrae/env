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
Model.new(:documents, 'Important documents') do

  split_into_chunks_of 50

  # System config, daemons, apps
  archive :documents do |a|

    a.root File.expand_path("~/Backup/local/Safebox")
    a.add "Archives/Commercial"
    a.add "Archives/Official"
    a.add "Archives/Payslips"
  end

  compress_with Gzip

  encrypt_with GPG do |encryption|

    encryption.keys = [ ENV['ARCHIVES_BACKUP_GPG_KEY'] ].inject({}) do |memo,key|
      memo[key] = `gpg -a --export "#{key}"`
      memo
    end

    encryption.recipients = ENV['ARCHIVES_BACKUP_GPG_KEY']
  end

  store_with S3 do |s3|
    s3.access_key_id     = ENV['ARCHIVES_BACKUP_S3_ACCESS_KEY_ID'].dup
    s3.secret_access_key = ENV['ARCHIVES_BACKUP_S3_SECRET_ACCESS_KEY'].dup
    s3.region            = ENV['ARCHIVES_BACKUP_S3_REGION'].dup
    s3.bucket            = ENV['ARCHIVES_BACKUP_S3_BUCKET'].dup
    s3.path              = ENV['ARCHIVES_BACKUP_S3_PATH'].dup
    s3.encryption        = :aes256
  end

  store_with Local do |local|
    local.path = File.expand_path("~/Transient/Backups")
    local.keep = 10
  end
end
