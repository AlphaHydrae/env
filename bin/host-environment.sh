# Shared host environment computation for ZSH prompt and tmux status bar.
#
# Reads:
#   HOST_ENVIRONMENT_FILE  – explicit path to env file (optional)
#   Falls back to: $HOME/.host-environment, then /etc/.host-environment
#
# Output (pipe-delimited, single line):
#   bg_color|fg_color|label
#
# Nothing is output if no environment file is found or it is empty.

host_environment_info() {
  local host_environment_file

  if [ -n "$HOST_ENVIRONMENT_FILE" ]; then
    host_environment_file="$HOST_ENVIRONMENT_FILE"
  elif [ -f "$HOME/.host-environment" ]; then
    host_environment_file="$HOME/.host-environment"
  elif [ -f "/etc/.host-environment" ]; then
    host_environment_file="/etc/.host-environment"
  fi

  [ ! -f "$host_environment_file" ] && return

  local label
  label="$(sed 's/[^A-Z0-9a-z_-]*//' "$host_environment_file")"
  [ -z "$label" ] && return

  local bg=white fg=black
  local normalized
  normalized="$(echo "$label" | tr '[:upper:]' '[:lower:]')"

  if [ "${normalized#pr}" != "$normalized" ]; then
    bg=red
    fg=white
    label="$(echo "$label" | tr '[:lower:]' '[:upper:]' | sed -E 's/^PR$|^PROD$/PRODUCTION/')"
  elif [ "${normalized#st}" != "$normalized" ]; then
    bg=yellow
    fg=black
  fi

  printf '%s|%s|%s\n' "$bg" "$fg" "$label"
}
