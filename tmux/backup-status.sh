#!/usr/bin/env bash
#
# Displays backup age as a Powerline-style tmux status segment.
#
# Uses the shared backup_status function from bin/backup-status.sh to compute
# backup age, then formats it for tmux.
#
# Reads environment variables:
#   PROMPT_BACKUP_DATA_DIR  – path to the directory whose newest file marks
#                             the most-recent backup timestamp.
#   PROMPT_BACKUP_AGE       – set to "off" to hide the segment entirely;
#                             set to "0" to show the icon without running a
#                             find (treat as "just backed up").
#
# The result is cached in a temp file for CACHE_TTL seconds so the find command
# does not run on every status-interval tick.

# Source the shared library
BACKUP_STATUS_LIB="$(dirname "$0")/../bin/backup-status.sh"
source "$BACKUP_STATUS_LIB"

CACHE_FILE="${TMPDIR:-/tmp}/tmux-backup-status-$$EUID"
CACHE_TTL=300   # seconds (5 minutes)

STATUS_BG='#262626'  # must match G0 in .tmux.conf
rarrow=''           # Powerline
backup_icon='💾'

output_segment() {
  local color="$1" label="$2"
  printf '#[fg=%s,bg=%s]%s#[fg=%s,bg=%s] %s ' \
    "$STATUS_BG" "$color" "$rarrow" \
    "$STATUS_BG" "$color" "$label"
}

# Portable mtime of a file (macOS stat vs GNU stat)
file_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null
}

# Emit cache and exit if recent enough.
if [ -f "$CACHE_FILE" ]; then
  cache_age=$(( $(date +%s) - $(file_mtime "$CACHE_FILE") ))
  if [ "$cache_age" -lt "$CACHE_TTL" ]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

compute_status() {
  local backup_age_days="$(backup_status)"

  # Empty output means PROMPT_BACKUP_AGE="off" – don't display anything.
  [ -z "$backup_age_days" ] && return

  # Format based on the returned numeric age.
  case "$backup_age_days" in
    "-2")
      # Just backed up (override: PROMPT_BACKUP_AGE="0")
      output_segment "colour245" "$backup_icon"
      ;;
    "-1")
      # Error: unconfigured or not found
      output_segment "red" "$backup_icon"
      ;;
    *)
      # Numeric age in days
      if [ "$backup_age_days" -lt 2 ]; then
        output_segment "green" "$backup_icon"
      elif [ "$backup_age_days" -lt 3 ]; then
        output_segment "yellow" "${backup_icon} ${backup_age_days}d"
      else
        output_segment "red" "${backup_icon} ${backup_age_days}d"
      fi
      ;;
  esac
}

# Write cache and emit
result="$(compute_status)"
printf '%s' "$result" | tee "$CACHE_FILE"
