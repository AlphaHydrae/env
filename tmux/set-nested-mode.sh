#!/usr/bin/env bash

mode="${1:-active}"
role="${2:-outer}"

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

# Colors must match .tmux.conf.
G0='#262626'
G1='#303030'
G3='#444444'
G4='#626262'
TC='#00abab'
TP='#875fff'

window_status_format_passive="#[fg=$G1,bg=colour237]#[fg=$G3,bg=colour237] #I▸#W#{?window_bell_flag,!,}#{?window_silence_flag,~,}#{?window_marked_flag,M,}#{?window_zoomed_flag, ZOOM,} #[fg=colour237,bg=$G1]"
window_status_format_active="#[fg=$G0,bg=colour237]#[fg=$TC,bg=colour237] #I▸#W#{?window_bell_flag,!,}#{?window_silence_flag,~,}#{?window_marked_flag,M,}#{?window_zoomed_flag, ZOOM,} #[fg=colour237,bg=$G0]"
window_status_current_format_active="#{?window_zoomed_flag,#[fg=$G0 bg=colour9],#[fg=$G0 bg=$TC]}#{?window_zoomed_flag,#[fg=$G0 bg=colour9 bold],#[fg=$G0 bg=$TC bold]} #I▸#W#{?window_bell_flag,!,}#{?window_silence_flag,~,}#{?window_marked_flag,M,}#{?window_zoomed_flag, ZOOM,} #{?window_zoomed_flag,#[fg=colour9 bg=$G0 none],#[fg=$TC bg=$G0 none]}"
window_status_current_format_passive_outer="#{?window_zoomed_flag,#[fg=$G0 bg=colour9],#[fg=$G0 bg=$TP]}#{?window_zoomed_flag,#[fg=$G0 bg=colour9 bold],#[fg=$G0 bg=$TP bold]} #I▸#W#{?window_bell_flag,!,}#{?window_silence_flag,~,}#{?window_marked_flag,M,}#{?window_zoomed_flag, ZOOM,} #{?window_zoomed_flag,#[fg=colour9 bg=$G1 none],#[fg=$TP bg=$G1 none]}"
window_status_current_format_passive_inner="#{?window_zoomed_flag,#[fg=$G0 bg=colour9],#[fg=$G0 bg=$G4]}#{?window_zoomed_flag,#[fg=$G0 bg=colour9 bold],#[fg=$G0 bg=$G4 bold]} #I▸#W#{?window_bell_flag,!,}#{?window_silence_flag,~,}#{?window_marked_flag,M,}#{?window_zoomed_flag, ZOOM,} #{?window_zoomed_flag,#[fg=colour9 bg=$G1 none],#[fg=$G4 bg=$G1 none]}"

if [ "$mode" = "active" ]; then
  tmux set -g @nested_passive 0
  tmux set -g @nested_mode active
  tmux set -g @nested_role "$role"
  tmux set -g status-style "fg=$G4,bg=$G0"
  tmux set -g window-status-format "$window_status_format_active"
  tmux set -g window-status-current-format "$window_status_current_format_active"
  tmux set -g window-status-style "fg=$TC,bg=$G0,none"
  tmux set -g window-status-last-style "fg=$TC,bg=$G0,bold"
  tmux set -g window-status-activity-style "fg=$TC,bg=$G0,bold"
  tmux set -g window-status-bell-style "fg=$TC,bg=$G0,bold"
  tmux set -g message-style "fg=$TC,bg=$G0"
  tmux set -g message-command-style "fg=$TC,bg=$G0"
  exit 0
fi

tmux set -g @nested_passive 1
tmux set -g @nested_mode "$mode"
tmux set -g @nested_role "$role"
tmux set -g status-style "fg=$G3,bg=$G1"
tmux set -g window-status-format "$window_status_format_passive"
tmux set -g window-status-style "fg=$G3,bg=$G1,none"
tmux set -g window-status-last-style "fg=$G3,bg=$G1,bold"
tmux set -g window-status-activity-style "fg=$G3,bg=$G1,bold"
tmux set -g window-status-bell-style "fg=$G3,bg=$G1,bold"
tmux set -g message-style "fg=$G3,bg=$G1"
tmux set -g message-command-style "fg=$G3,bg=$G1"

if [ "$mode" = "passive-outer" ]; then
  tmux set -g window-status-current-format "$window_status_current_format_passive_outer"
else
  tmux set -g window-status-current-format "$window_status_current_format_passive_inner"
fi
