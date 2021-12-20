# Set up fzf
# ----------
if command -v brew &>/dev/null; then # Homebrew installation
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ ! "$PATH" == *${HOMEBREW_PREFIX}/opt/fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}${HOMEBREW_PREFIX}/opt/fzf/bin"
  fi

  # Key bindings
  [ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh" ] && . "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
  # Auto-completion
  [ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" ] && . "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh"
elif [ -d /opt/local/fzf/shell ]; then # Git installation
  # Key bindings
  [ -f /opt/local/fzf/shell/key-bindings.zsh ] && . /opt/local/fzf/shell/key-bindings.zsh
  # Auto-completion
  [ -f /opt/local/fzf/shell/completion.zsh ] && . /opt/local/fzf/shell/completion.zsh
elif [ -d /usr/share/doc/fzf/examples ]; then # APT installation
  # Key bindings
  [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && . /usr/share/doc/fzf/examples/key-bindings.zsh
  # Auto-completion
  if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
    . /usr/share/doc/fzf/examples/completion.zsh
  elif [ -f /usr/share/zsh/vendor-completions/_fzf ]; then
    . /usr/share/zsh/vendor-completions/_fzf
  fi
fi

