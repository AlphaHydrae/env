
export LANG="en_US.UTF-8"

# nodenv
if [ -s /usr/local/bin/nodenv ]; then
  eval "$(/usr/local/bin/nodenv init -)"
else
  export PATH=$HOME/.nodenv/bin:$HOME/.nodenv/shims:$PATH
fi

# rbenv
export PATH=$HOME/.rbenv/shims:$PATH
