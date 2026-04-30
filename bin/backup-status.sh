# Backup status computation script
#
# Reads:
#   PROMPT_BACKUP_AGE       - set to "off" to disable; "0" to force success
#   PROMPT_BACKUP_DATA_DIR  - path to directory whose newest file is the backup time
#
# Output:
#   -2  if PROMPT_BACKUP_AGE="0" (override: treat as just backed up)
#   -1  if PROMPT_BACKUP_DATA_DIR is not configured or no backup file found
#   N   days since backup (integer >= 0)

backup_status() {
  local backup_age="${PROMPT_BACKUP_AGE}"
  local backup_data_dir="${PROMPT_BACKUP_DATA_DIR}"

  [ "$backup_age" = "off" ] && return

  if [ "$backup_age" = "0" ]; then
    echo -n "-2"
    return
  fi

  # No backup root configured means there is no usable backup signal.
  if [ -z "$backup_data_dir" ]; then
    echo -n "-1"
    return
  fi

  local latest_timestamp
  # Find newest backup file mtime using platform-appropriate tooling.
  if command -v gfind >/dev/null 2>&1; then
    latest_timestamp=$(
      gfind "$backup_data_dir" -type f -printf '%T@\n' 2>/dev/null \
        | cut -d. -f1 | sort -n | tail -1
    )
  elif [ "$(uname)" = "Darwin" ]; then
    latest_timestamp=$(
      find "$backup_data_dir" -type f \
        -exec stat -f %m {} + 2>/dev/null \
        | sort -n | tail -1
    )
  else
    latest_timestamp=$(
      find "$backup_data_dir" -type f \
        -exec stat -c %Y {} + 2>/dev/null \
        | sort -n | tail -1
    )
  fi

  if [ -z "$latest_timestamp" ]; then
    echo -n "-1"
    return
  fi

  local diff_days=$(( ( $(date +%s) - latest_timestamp ) / 86400 ))

  # Clock skew or future mtimes should not produce a negative day count.
  [ "$diff_days" -lt 0 ] && diff_days=0

  echo -n "$diff_days"
}