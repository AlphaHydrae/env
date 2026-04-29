#!/usr/bin/env bash

PROMPT_CONTEXT_LIB="$(dirname "$0")/../bin/prompt-context.sh"
source "$PROMPT_CONTEXT_LIB"

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

IFS='|' read -r ssh_flag user host is_root <<EOF
$(prompt_context_info)
EOF

[ -z "$user" ] && exit 0

out=''
prev_bg="$status_bg"

if [ "$ssh_flag" = "1" ]; then
  out+="$(segment_sep "$prev_bg" "green")"
  out+="$(segment_body "black" "green" "SSH")"
  prev_bg='green'
fi

context_text=''
[ "$is_root" = "1" ] && context_text+='#'
context_text+="${user}@${host}"

out+="$(segment_sep "$prev_bg" "magenta")"
out+="$(segment_body "black" "magenta" "$context_text")"
out+="$(segment_sep "magenta" "$status_bg")"

printf '%s' "$out"