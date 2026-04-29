#!/usr/bin/env bash

BACKUP_STATUS_LIB="$(dirname "$0")/../bin/backup-status.sh"
CPU_MEM_STATUS_SCRIPT="$(dirname "$0")/cpu-mem-status.sh"

source "$BACKUP_STATUS_LIB"

status_bg='#262626'
time_bg='colour240'
rarrow=''
backup_icon='💾'
backup_cache_file="${TMPDIR:-/tmp}/tmux-right-status-backup-$EUID"
backup_cache_ttl=300

file_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null
}

backup_label_and_color() {
  local backup_age

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

segment_sep() {
  local left_bg="$1"
  local right_bg="$2"

  printf '#[fg=%s,bg=%s]%s' "$left_bg" "$right_bg" "$rarrow"
}

segment_divider() {
  local left_bg="$1"
  local right_bg="$2"

  printf '#[fg=%s,bg=%s]▐' "$right_bg" "$left_bg"
}

segment_body() {
  local bg="$1"
  local text="$2"

  printf '#[fg=black,bg=%s]%s' "$bg" "$text"
}

right_status=''
previous_bg="$status_bg"

IFS='|' read -r backup_color backup_label <<EOF
$(backup_label_and_color)
EOF

if [ -n "$backup_color" ] && [ -n "$backup_label" ]; then
  right_status+="$(segment_sep "$previous_bg" "$backup_color")"
  right_status+="$(segment_body "$backup_color" " $backup_label ")"
  previous_bg="$backup_color"
fi

read -r cpu_pct cpu_color mem_pct mem_color < <("$CPU_MEM_STATUS_SCRIPT")
cpu_pct=${cpu_pct:-00}
cpu_color=${cpu_color:-colour33}
mem_pct=${mem_pct:-00}
mem_color=${mem_color:-colour33}
time_text="$(date +%H:%M:%S)"

right_status+="$(segment_sep "$previous_bg" "$cpu_color")"
right_status+="$(segment_body "$cpu_color" " C${cpu_pct}")"
right_status+="$(segment_divider "$cpu_color" "$mem_color")"
right_status+="$(segment_body "$mem_color" "M${mem_pct} ")"
right_status+="$(segment_sep "$mem_color" "$time_bg")"
right_status+="$(segment_body "$time_bg" " ${time_text} ")"

printf '%s' "$right_status"