#!/usr/bin/env bash

# Left status renderer for tmux.
#
# Displayed features (left-to-right):
# - SSH badge when inside an SSH context.
# - user@host context (with root marker when relevant).
# - host environment badge (for production/staging/etc when configured).
#
# Rendering primitives are shared with right-status so separators/colors stay consistent.

PROMPT_CONTEXT_LIB="$(dirname "$0")/../bin/prompt-context.sh"
HOST_ENV_LIB="$(dirname "$0")/../bin/host-environment.sh"
STATUS_LIB="$(dirname "$0")/lib/status-lib.sh"
source "$PROMPT_CONTEXT_LIB"
source "$HOST_ENV_LIB"
source "$STATUS_LIB"

mode="${1:-active}"

out=''
prev_bg=''

append_segment() {
  local fg="$1"
  local bg="$2"
  local text="$3"

  if [[ -n "$prev_bg" ]]; then
    out+="$(status_segment_sep "$prev_bg" "$bg")"
  fi

  out+="$(status_segment_body "$fg" "$bg" "$text")"
  prev_bg="$bg"
}

IFS='|' read -r ssh_flag user host is_root <<EOF
$(prompt_context_info)
EOF

# For regular local shells, prompt_context_info returns empty and this stays hidden.
if [[ -n "$user" ]]; then
  if [[ "$ssh_flag" == "1" ]]; then
    append_segment "black" "green" "SSH"
  fi

  context_text=''
  [[ "$is_root" == "1" ]] && context_text+='#'
  context_text+="${user}@${host}"
  append_segment "black" "magenta" "$context_text"
fi

IFS='|' read -r env_bg env_fg env_label <<EOF
$(host_environment_info)
EOF

# Environment badge is optional and only shown when host-environment is configured.
if [[ -n "$env_bg" ]]; then
  append_segment "$env_fg" "$env_bg" "$env_label"
fi

printf '%s' "$out"
