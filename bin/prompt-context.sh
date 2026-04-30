# Shared prompt context computation for ZSH prompt and tmux status bar.
#
# Output (pipe-delimited, single line):
#   ssh_flag|user|host|is_root
#
# Nothing is output when context should be hidden.

prompt_context_info() {
  local current_user default_user ssh_flag host is_root

  if [ -n "$USERNAME" ]; then
    current_user="$USERNAME"
  elif [ -n "$USER" ]; then
    current_user="$USER"
  else
    current_user="$(id -un 2>/dev/null)"
  fi

  if [ -n "$DEFAULT_USER" ]; then
    default_user="$DEFAULT_USER"
  else
    default_user="$current_user"
  fi

  ssh_flag=0
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_CONNECTION" ]; then
    ssh_flag=1
  fi

  # Context is hidden for the default local user unless running over SSH.
  if [ "$current_user" = "$default_user" ] && [ "$ssh_flag" -eq 0 ]; then
    return
  fi

  # Keep host short to avoid noisy prompt/status segments.
  if [ -n "$HOSTNAME" ]; then
    host="${HOSTNAME%%.*}"
  else
    host="$(hostname -s 2>/dev/null || hostname 2>/dev/null)"
    host="${host%%.*}"
  fi

  is_root=0
  if [ "$(id -u 2>/dev/null)" = "0" ]; then
    is_root=1
  fi

  printf '%s|%s|%s|%s\n' "$ssh_flag" "$current_user" "$host" "$is_root"
}