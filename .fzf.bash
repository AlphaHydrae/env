# Setup fzf
# ---------
if command -v brew &>/dev/null; then
  # Homebrew
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ ! "$PATH" == *${HOMEBREW_PREFIX}/opt/fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}${HOMEBREW_PREFIX}/opt/fzf/bin"
  fi

  # Auto-completion
  [[ $- == *i* ]] && source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.bash" 2> /dev/null

  # Key bindings
  source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.bash"
elif test -d /opt/local/fzf/shell; then
  # Git
  source /opt/local/fzf/shell/key-bindings.bash
  source /opt/local/fzf/shell/completion.bash
elif test -d /usr/share/doc/fzf/examples; then
  # APT
  source /usr/share/doc/fzf/examples/key-bindings.bash
  source /usr/share/doc/fzf/examples/completion.bash
fi
