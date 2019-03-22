
export LANG="en_US.UTF-8"
export PATH="/usr/local/bin:$PATH"

# nodenv
if [ -s /usr/local/bin/nodenv ]; then
  eval "$(/usr/local/bin/nodenv init -)"
else
  export PATH=$HOME/.nodenv/bin:$HOME/.nodenv/shims:$PATH
fi

# rbenv
if [ -s /usr/local/bin/rbenv ]; then
  eval "$(/usr/local/bin/rbenv init -)"
else
  export PATH=$HOME/.rbenv/shims:$PATH
fi
