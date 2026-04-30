#!/usr/bin/env bash

# Apply nested-mode styling and state in one place.
#
# Features:
# - Keeps active/passive and inner/outer visual profiles consistent.
# - Publishes current nested mode/role options consumed by status renderers.
# - Applies full window/message/status style bundles for the selected mode.

mode="${1:-active}"
role="${2:-outer}"
STATUS_LIB="$(dirname "$0")/lib/status-lib.sh"

source "$STATUS_LIB"

case "$mode" in
  active|passive-outer|passive-inner)
    ;;
  *)
    mode="active"
    ;;
esac

case "$role" in
  inner|outer)
    ;;
  *)
    role="outer"
    ;;
esac

# Read semantic theme colors from tmux options with safe shared fallbacks.
BGB="$(tmux_theme_get '@theme_bg_base' '#262626')"
BGM="$(tmux_theme_get '@theme_bg_muted' '#303030')"
FGS="$(tmux_theme_get '@theme_fg_subtle' '#444444')"
BGP="$(tmux_theme_get '@theme_bg_passive' '#626262')"
FGAA="$(tmux_theme_get '@theme_fg_accent_active' '#00abab')"
FGAP="$(tmux_theme_get '@theme_fg_accent_passive' '#875fff')"
SEGMENT_SEPARATOR="$(tmux_segment_separator)"
WINDOW_INDICATORS='#{?window_bell_flag,!,}#{?window_silence_flag,~,}#{?window_marked_flag,M,}#{?window_zoomed_flag, ZOOM,}'

build_window_status_format() {
  local left_arrow_fg="$1"
  local title_fg="$2"
  local right_arrow_bg="$3"

  printf '#[fg=%s,bg=colour237]%s#[fg=%s,bg=colour237] #I▸#W%s #[fg=colour237,bg=%s]%s' \
    "$left_arrow_fg" "$SEGMENT_SEPARATOR" "$title_fg" "$WINDOW_INDICATORS" "$right_arrow_bg" "$SEGMENT_SEPARATOR"
}

build_window_current_format() {
  local accent_bg="$1"
  local tail_bg="$2"

  printf '#{?window_zoomed_flag,#[fg=%s bg=colour9],#[fg=%s bg=%s]}%s#{?window_zoomed_flag,#[fg=%s bg=colour9 bold],#[fg=%s bg=%s bold]} #I▸#W%s #{?window_zoomed_flag,#[fg=colour9 bg=%s none],#[fg=%s bg=%s none]}%s' \
    "$BGB" "$BGB" "$accent_bg" "$SEGMENT_SEPARATOR" \
    "$BGB" "$BGB" "$accent_bg" "$WINDOW_INDICATORS" \
    "$tail_bg" "$accent_bg" "$tail_bg" "$SEGMENT_SEPARATOR"
}

window_status_format_passive="$(build_window_status_format "$BGM" "$FGS" "$BGM")"
window_status_format_active="$(build_window_status_format "$BGB" "$FGAA" "$BGB")"
window_status_current_format_active="$(build_window_current_format "$FGAA" "$BGB")"
window_status_current_format_passive_outer="$(build_window_current_format "$FGAP" "$BGM")"
window_status_current_format_passive_inner="$(build_window_current_format "$BGP" "$BGM")"

if [ "$mode" = "active" ]; then
  tmux set -g @nested_passive 0
  tmux set -g @nested_mode active
  tmux set -g @nested_role "$role"
  tmux set -g status-style "fg=$BGP,bg=$BGB"
  tmux set -g window-status-format "$window_status_format_active"
  tmux set -g window-status-current-format "$window_status_current_format_active"
  tmux set -g window-status-style "fg=$FGAA,bg=$BGB,none"
  tmux set -g window-status-last-style "fg=$FGAA,bg=$BGB,bold"
  tmux set -g window-status-activity-style "fg=$FGAA,bg=$BGB,bold"
  tmux set -g window-status-bell-style "fg=$FGAA,bg=$BGB,bold"
  tmux set -g message-style "fg=$FGAA,bg=$BGB"
  tmux set -g message-command-style "fg=$FGAA,bg=$BGB"
  exit 0
fi

tmux set -g @nested_passive 1
tmux set -g @nested_mode "$mode"
tmux set -g @nested_role "$role"
tmux set -g status-style "fg=$FGS,bg=$BGM"
tmux set -g window-status-format "$window_status_format_passive"
tmux set -g window-status-style "fg=$FGS,bg=$BGM,none"
tmux set -g window-status-last-style "fg=$FGS,bg=$BGM,bold"
tmux set -g window-status-activity-style "fg=$FGS,bg=$BGM,bold"
tmux set -g window-status-bell-style "fg=$FGS,bg=$BGM,bold"
tmux set -g message-style "fg=$FGS,bg=$BGM"
tmux set -g message-command-style "fg=$FGS,bg=$BGM"

if [ "$mode" = "passive-outer" ]; then
  tmux set -g window-status-current-format "$window_status_current_format_passive_outer"
else
  tmux set -g window-status-current-format "$window_status_current_format_passive_inner"
fi
