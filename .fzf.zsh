# Setup fzf
# ---------
if command -v brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ ! "$PATH" == *${HOMEBREW_PREFIX}/opt/fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}${HOMEBREW_PREFIX}/opt/fzf/bin"
  fi

  # Auto-completion
  # ---------------
  [[ $- == *i* ]] && source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" 2> /dev/null

  # Key bindings
  # ------------
  source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
elif test -d /opt/local/fzf/shell; then
  # Git
  source /opt/local/fzf/shell/key-bindings.zsh
  source /opt/local/fzf/shell/completion.zsh
elif test -d /usr/share/doc/fzf/examples; then
  # APT
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi
