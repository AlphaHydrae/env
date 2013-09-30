
notify true

Dotenv.load File.expand_path('~/.env')
box env(:name, :root, :encfs_config, :password_file, prefix: :boxafe_)
