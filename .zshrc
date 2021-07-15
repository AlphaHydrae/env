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
ZSH_THEME="agnoster"

# Hide the default user from the prompt.
DEFAULT_USER=`whoami`

# Use hyphen-insensitive completion (_ and - will be interchangeable).
HYPHEN_INSENSITIVE="true"

# Disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to display red dots whilst waiting for
# completion. Caution: this setting can cause issues with multiline prompts
# (zsh 5.7.1 and newer seem to work) See
# https://github.com/ohmyzsh/ohmyzsh/issues/5765.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

. $ZSH/oh-my-zsh.sh

# User configuration
# ==================


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

# Load configuration specific to the local machine.
test -f ~/.zshlocal && . ~/.zshlocal

# Load private configuration.
test -f ~/.zshprivate && . ~/.zshprivate

# https://direnv.net
hash direnv 2>/dev/null && eval "$(direnv hook zsh)"

# https://www.jenv.be
if [ -s /usr/local/bin/jenv ]; then
  eval "$(jenv init -)"
else
  export PATH=$HOME/.jenv/bin:$HOME/.jenv/shims:$PATH
fi

# rbenv
if [ -s /usr/local/bin/rbenv ]; then
  eval "$(/usr/local/bin/rbenv init -)"
else
  export PATH=$HOME/.rbenv/shims:$PATH
fi

# nodenv
if [ -s /usr/local/bin/nodenv ]; then
  eval "$(/usr/local/bin/nodenv init -)"
else
  export PATH=$HOME/.nodenv/bin:$HOME/.nodenv/shims:$PATH
fi

# https://brew.sh
[ -d /opt/homebrew ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
[ -d /usr/local/sbin ] && export PATH="/usr/local/sbin:$PATH"

# Disable Homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# https://asdf-vm.com
test -s /opt/homebrew/opt/asdf/asdf.sh && . /opt/homebrew/opt/asdf/asdf.sh
test -s /usr/local/opt/asdf/asdf.sh && . /usr/local/opt/asdf/asdf.sh
test -f ~/.asdf/plugins/java/set-java-home.zsh && . ~/.asdf/plugins/java/set-java-home.zsh # Java plugin

# https://github.com/junegunn/fzf
test -f ~/.fzf.zsh && . ~/.fzf.zsh

# Further customization
# =====================
# See $ZSH_CUSTOM directory.
