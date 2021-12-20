# Set up fzf
# ----------
if command -v brew &>/dev/null; then # Homebrew installation
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ ! "$PATH" == *${HOMEBREW_PREFIX}/opt/fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}${HOMEBREW_PREFIX}/opt/fzf/bin"
  fi

  # Key bindings
  [ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.bash" ] && . "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.bash"
  # Auto-completion
  [ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.bash" ] && . "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.bash"
elif [ -d /opt/local/fzf/shell ]; then # Git installation
  # Key bindings
  [ -f /opt/local/fzf/shell/key-bindings.bash ] && . /opt/local/fzf/shell/key-bindings.bash
  # Auto-completion
  [ -f /opt/local/fzf/shell/completion.bash ] && . /opt/local/fzf/shell/completion.bash
elif [ -d /usr/share/doc/fzf/examples ]; then # APT installation
  # Key bindings
  [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
  # Auto-completion
  if [ -f /usr/share/doc/fzf/examples/completion.bash ]; then
    . /usr/share/doc/fzf/examples/completion.bash
  elif [ -f /usr/share/bash-completion/completions/fzf ]; then
    . /usr/share/bash-completion/completions/fzf
  fi
fi
