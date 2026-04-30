#!/usr/bin/env bash

# Toggle control handoff between outer and inner tmux sessions.
#
# Features:
# - Passive mode: hand prefix/control to inner tmux and mute outer controls.
# - Active mode: reclaim local controls and restore the saved prefix.
# - Uses explicit M-F11/M-F12 signals to coordinate outer/inner state.

state="${1:-active}"
set_mode_script="$(dirname "$0")/set-nested-mode.sh"

case "$state" in
  active|passive)
    ;;
  *)
    state="active"
    ;;
esac

if [[ "$state" == "passive" ]]; then
  # Preserve the configured prefix before handing control to the inner tmux.
  current_prefix="$(tmux show-options -gv prefix 2>/dev/null || echo 'C-b')"
  tmux set -g @nested_saved_prefix "$current_prefix"

  # Signal the inner tmux first, then make this server passive and hand prefix over.
  tmux send-keys M-F12
  bash "$set_mode_script" passive-outer outer
  tmux set -g prefix M-F12
  tmux unbind -T root C-p
  tmux unbind -T root C-h
  tmux unbind -T root C-z
  tmux unbind -T root C-q
  tmux unbind -T root C-s
  exit 0
fi

# Restore local controls and notify inner tmux to exit passive mode.
tmux send-keys M-F11
bash "$set_mode_script" active outer
saved_prefix="$(tmux show-options -gv @nested_saved_prefix 2>/dev/null || echo 'C-b')"
tmux set -g prefix "$saved_prefix"
tmux bind -T root C-p display-popup -E ""
tmux bind -T root C-h display-popup -E "htop"
tmux bind -T root C-z resize-pane -Z
tmux bind-key -T root C-q send-keys -t :. C-c '!!' Enter Enter
tmux bind-key -T root C-s if -F "#{pane_synchronized}" "set-window-option synchronize-panes off" "set-window-option synchronize-panes on"
