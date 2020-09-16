
export LANG="en_US.UTF-8"
export PATH="/usr/local/bin:$PATH"

# asdf
if [ -s /usr/local/opt/asdf/asdf.sh ]; then
  source /usr/local/opt/asdf/asdf.sh
fi

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
