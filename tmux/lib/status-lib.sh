#!/usr/bin/env bash

# Shared tmux status helpers:
#
# - Centralize common rendering primitives used by left/right status scripts.
# - Read semantic theme colors from tmux options with safe fallbacks.

# Read a tmux option value with fallback when outside tmux or unset.
tmux_theme_get() {
  local option_name="$1"
  local fallback="$2"
  local value

  value="$(tmux show-options -gv "$option_name" 2>/dev/null)"
  if [ -n "$value" ]; then
    printf '%s' "$value"
  else
    printf '%s' "$fallback"
  fi
}

# Base status background follows active/passive mode.
tmux_mode_status_bg() {
  local mode="$1"
  case "$mode" in
    passive-*) tmux_theme_get '@theme_bg_muted' '#303030' ;;
    *) tmux_theme_get '@theme_bg_base' '#262626' ;;
  esac
}

# Shared segment separator used by status scripts and window-format helpers.
tmux_segment_separator() {
  tmux_theme_get '@theme_segment_separator' ''
}

status_segment_sep() {
  local left_bg="$1"
  local right_bg="$2"
  printf '#[fg=%s,bg=%s]%s' "$left_bg" "$right_bg" "$(tmux_segment_separator)"
}

status_segment_body() {
  local fg="$1"
  local bg="$2"
  local text="$3"
  printf '#[fg=%s,bg=%s] %s ' "$fg" "$bg" "$text"
}

status_segment_body_black_fg() {
  local bg="$1"
  local text="$2"
  printf '#[fg=black,bg=%s]%s' "$bg" "$text"
}

status_segment_divider() {
  local left_bg="$1"
  local right_bg="$2"
  printf '#[fg=%s,bg=%s]▐' "$right_bg" "$left_bg"
}
