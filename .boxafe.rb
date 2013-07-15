
notify true

Dotenv.load File.expand_path('~/.env')
box env(:name, :root, :encfs_config, :keychain, prefix: :boxafe_)
