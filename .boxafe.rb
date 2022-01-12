
notify true

Dotenv.load File.expand_path('~/.secrets')
box env(:name, :root, :mount, :encfs_config, :password_file, prefix: :boxafe_)
