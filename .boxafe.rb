
Dotenv.load File.expand_path('~/.env')
box env(:name, :root, :config, :keychain, prefix: :boxafe_)
