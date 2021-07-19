#          __                                     __
#   ____  / /_     ____ ___  __  __   ____  _____/ /_
#  / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \
# / /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / /
# \____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/
#                         /____/
#
# https://ohmyz.sh
#

# Path to the oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set the theme. See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes.
ZSH_THEME="alphahydrae"

# Hide the default user from the prompt.
DEFAULT_USER=`whoami`

# Use hyphen-insensitive completion (_ and - will be interchangeable).
HYPHEN_INSENSITIVE="true"

# Disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# How often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to display red dots whilst waiting for
# completion. Caution: this setting can cause issues with multiline prompts
# (zsh 5.7.1 and newer seem to work) See
# https://github.com/ohmyzsh/ohmyzsh/issues/5765.
COMPLETION_WAITING_DOTS="true"

# Plugins to load. Standard plugins can be found in "$ZSH/plugins/". Custom
# plugins may be added to "$ZSH_CUSTOM/plugins/".
plugins=(
  asdf                 # completions for `asdf` - https://asdf-vm.com
  aws                  # completions for `aws` - https://aws.amazon.com/cli/
  bundler              # completions for `bundler` - https://bundler.io
  composer             # completions for `composer` - https://getcomposer.org
  direnv               # enables direnv - https://direnv.net
  docker               # completions for `docker` - https://www.docker.com
  docker-compose       # completions for `docker-compose` - https://docs.docker.com/compose/
  dotenv               # automatically load `.env` files - https://github.com/motdotla/dotenv
  gem                  # completions for `gem` - https://rubygems.org
  git-extras           # completions for https://github.com/tj/git-extras
  golang               # completions for `go` - https://golang.org
  heroku               # completions for `heroku` - https://devcenter.heroku.com/articles/heroku-cli
  httpie               # completions for `http` - https://httpie.io
  mix                  # completions for `mix` - https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html
  mvn                  # completions for `mvn` - https://maven.apache.org
  ng                   # completions for `ng` - https://angular.io/cli
  npm                  # completions for `npm` - https://www.npmjs.com
  rails                # completions for `rails` - https://rubyonrails.org
  rebar                # completions for `rebar3` - https://rebar3.org
  redis-cli            # completions for `redis-cli` - https://redis.io
  rust                 # completions for `rustc` - https://www.rust-lang.org
  rustup               # completions for `rustup` - https://rustup.rs
  vagrant              # completions for `vagrant` - https://www.vagrantup.com
  zsh-autosuggestions  # Fish-like autosuggestions - https://github.com/zsh-users/zsh-autosuggestions#readme
)

# Load Oh My ZSH.
. $ZSH/oh-my-zsh.sh

# User configuration
# ==================

# Use 256 colors.
export TERM="xterm-256color"

# Save a truckload of commands in the history.
HISTFILE=~/.zshhistory
HISTSIZE=300000
SAVEHIST=300000

# Customize key bindings.
bindkey -v # vim key bindings
bindkey '^d' delete-char # delete key
bindkey '^?' backward-delete-char # backspace key
bindkey "^[[3~" delete-char # delete key for iterm 2
bindkey "^[3;5~" delete-char # delete key for iterm 2

# Load private configuration.
[ -f ~/.zshprivate ] && . ~/.zshprivate

# Load configuration specific to the local machine.
[ -f ~/.zshlocal ] && . ~/.zshlocal


# Composer - https://getcomposer.org
# ==================================
[ -d "$HOME/.composer" ] && export PATH="$HOME/.composer/vendor/bin:$PATH"

# jenv - https://www.jenv.be
# ==========================
if [ -s /usr/local/bin/jenv ]; then
  eval "$(jenv init -)"
elif [ -d "$HOME/.jenv" ]; then
  export PATH="$HOME/.jenv/bin:$HOME/.jenv/shims:$PATH"
fi

# rbenv - https://github.com/rbenv/rbenv
# ======================================
if [ -s /usr/local/bin/rbenv ]; then
  eval "$(/usr/local/bin/rbenv init -)"
elif [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/shims:$PATH"
fi

# nodenv - https://github.com/nodenv/nodenv
# =========================================
if [ -s /usr/local/bin/nodenv ]; then
  eval "$(/usr/local/bin/nodenv init -)"
elif [ -d "$HOME/.nodenv" ]; then
  export PATH="$HOME/.nodenv/bin:$HOME/.nodenv/shims:$PATH"
fi

# Homebrew - https://brew.sh
# ==========================
[ -d /opt/homebrew ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
[ -d /usr/local/sbin ] && export PATH="/usr/local/sbin:$PATH"

# Disable Homebrew analytics.
export HOMEBREW_NO_ANALYTICS=1

# asdf - https://asdf-vm.com
# ==========================
test -s /opt/homebrew/opt/asdf/asdf.sh && . /opt/homebrew/opt/asdf/asdf.sh
test -s /usr/local/opt/asdf/asdf.sh && . /usr/local/opt/asdf/asdf.sh
test -f ~/.asdf/plugins/java/set-java-home.zsh && . ~/.asdf/plugins/java/set-java-home.zsh # Java plugin

# fzf - https://github.com/junegunn/fzf
# =====================================
[ -f ~/.fzf.zsh ] && . ~/.fzf.zsh

# Further customization
# =====================
# See $ZSH_CUSTOM directory.
