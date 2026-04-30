#!/usr/bin/env bash

# Right status renderer for tmux.
#
# Displayed features (left-to-right):
# - Backup freshness indicator (when configured).
# - CPU usage.
# - Memory usage.
# - Clock (hidden for inner nested sessions to reduce duplication).
#
# Passive modes intentionally mute metric colors so nested focus remains clear.

BACKUP_STATUS_LIB="$(dirname "$0")/../bin/backup-status.sh"
CPU_MEM_STATUS_SCRIPT="$(dirname "$0")/cpu-mem-status.sh"
STATUS_LIB="$(dirname "$0")/lib/status-lib.sh"

source "$BACKUP_STATUS_LIB"
source "$STATUS_LIB"

status_bg="$(tmux_mode_status_bg "${1:-active}")"
time_bg='colour240'
backup_icon='💾'
backup_cache_ttl=300
mode="${1:-active}"
role="${2:-outer}"

tmux_backup_cache_key() {
  # Different tmux servers/sockets should not share one cache file.
  local socket_path
  socket_path="$(tmux display-message -p '#{socket_path}' 2>/dev/null)"
  if [ -z "$socket_path" ]; then
    printf '%s' "$EUID"
    return
  fi

  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$socket_path" | shasum -a 1 | awk '{print $1}'
  else
    printf '%s' "$socket_path" | awk '{gsub(/[^A-Za-z0-9]/, "_"); print}'
  fi
}

backup_cache_file="${TMPDIR:-/tmp}/tmux-right-status-backup-$(tmux_backup_cache_key)"

if [[ "$mode" == passive-* ]]; then
  time_bg='colour241'
  passive_cpu_bg='colour240'
  passive_mem_bg='colour241'
fi

file_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null
}

backup_label_and_color() {
  local backup_age

  # Cache backup state to avoid expensive disk scans on each status refresh tick.
  if [ -f "$backup_cache_file" ]; then
    local cache_age
    cache_age=$(( $(date +%s) - $(file_mtime "$backup_cache_file") ))
    if [ "$cache_age" -lt "$backup_cache_ttl" ]; then
      cat "$backup_cache_file"
      return
    fi
  fi

  unset PROMPT_BACKUP_AGE
  backup_age="$(backup_status)"

  case "$backup_age" in
    '')
      printf '\n' | tee "$backup_cache_file"
      ;;
    '-2')
      printf '%s|%s\n' 'colour245' "$backup_icon" | tee "$backup_cache_file"
      ;;
    '-1')
      printf '%s|%s\n' 'red' "$backup_icon" | tee "$backup_cache_file"
      ;;
    *)
      if [ "$backup_age" -lt 2 ]; then
        printf '%s|%s\n' 'green' "$backup_icon" | tee "$backup_cache_file"
      elif [ "$backup_age" -lt 3 ]; then
        printf '%s|%s %sd\n' 'yellow' "$backup_icon" "$backup_age" | tee "$backup_cache_file"
      else
        printf '%s|%s %sd\n' 'red' "$backup_icon" "$backup_age" | tee "$backup_cache_file"
      fi
      ;;
  esac
}

right_status=''
previous_bg="$status_bg"

IFS='|' read -r backup_color backup_label <<EOF
$(backup_label_and_color)
EOF

if [ -n "$backup_color" ] && [ -n "$backup_label" ]; then
  if [[ "$mode" == passive-* ]]; then
    backup_color='colour240'
  fi
  right_status+="$(status_segment_sep "$previous_bg" "$backup_color")"
  right_status+="$(status_segment_body_black_fg "$backup_color" " $backup_label ")"
  previous_bg="$backup_color"
fi

read -r cpu_pct cpu_color mem_pct mem_color < <("$CPU_MEM_STATUS_SCRIPT")
cpu_pct=${cpu_pct:-00}
cpu_color=${cpu_color:-colour33}
mem_pct=${mem_pct:-00}
mem_color=${mem_color:-colour33}

if [[ "$mode" == passive-* ]]; then
  # Passive mode keeps these neutral regardless of instantaneous metric spikes.
  cpu_color="$passive_cpu_bg"
  mem_color="$passive_mem_bg"
fi

time_text="$(date +%H:%M:%S)"

right_status+="$(status_segment_sep "$previous_bg" "$cpu_color")"
right_status+="$(status_segment_body_black_fg "$cpu_color" " C${cpu_pct}")"
right_status+="$(status_segment_divider "$cpu_color" "$mem_color")"
right_status+="$(status_segment_body_black_fg "$mem_color" "M${mem_pct} ")"

if [[ "$role" != "inner" ]]; then
  right_status+="$(status_segment_sep "$mem_color" "$time_bg")"
  right_status+="$(status_segment_body_black_fg "$time_bg" " ${time_text} ")"
fi

printf '%s' "$right_status"