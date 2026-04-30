#!/usr/bin/env bash

PROMPT_CONTEXT_LIB="$(dirname "$0")/../bin/prompt-context.sh"
HOST_ENV_LIB="$(dirname "$0")/../bin/host-environment.sh"
source "$PROMPT_CONTEXT_LIB"
source "$HOST_ENV_LIB"

mode="${1:-active}"
status_bg='#262626'
rarrow=''

if [[ "$mode" == passive-* ]]; then
  status_bg='#303030'
fi

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

out=''
prev_bg=''

append_segment() {
  local fg="$1"
  local bg="$2"
  local text="$3"

  if [[ -n "$prev_bg" ]]; then
    out+="$(segment_sep "$prev_bg" "$bg")"
  fi

  out+="$(segment_body "$fg" "$bg" "$text")"
  prev_bg="$bg"
}

IFS='|' read -r ssh_flag user host is_root <<EOF
$(prompt_context_info)
EOF

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

if [[ -n "$env_bg" ]]; then
  append_segment "$env_fg" "$env_bg" "$env_label"
fi

printf '%s' "$out"
