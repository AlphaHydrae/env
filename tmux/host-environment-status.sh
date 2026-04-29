#!/usr/bin/env bash

HOST_ENV_LIB="$(dirname "$0")/../bin/host-environment.sh"
source "$HOST_ENV_LIB"

status_bg='#262626'
rarrow=''

segment_sep() {
  local left_bg="$1"
  local right_bg="$2"
  printf '#[fg=%s,bg=%s]%s' "$left_bg" "$right_bg" "$rarrow"
}

segment_body() {
  local fg="$1"
  local bg="$2"
  local text="$3"
  printf '#[fg=%s,bg=%s] %s ' "$fg" "$bg" "$text"
}

IFS='|' read -r env_bg env_fg env_label <<EOF
$(host_environment_info)
EOF

[ -z "$env_bg" ] && exit 0

printf '%s' "$(segment_sep "$status_bg" "$env_bg")$(segment_body "$env_fg" "$env_bg" "$env_label")$(segment_sep "$env_bg" "$status_bg")"