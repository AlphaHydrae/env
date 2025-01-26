# vim:ft=zsh ts=2 sw=2 sts=2
#
# AlphaHydrae's Theme
# Based on agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts). Make
# sure you have a recent version: the code points that Powerline uses changed
# in 2012, and older versions will display incorrectly, in confusing ways.



# Hooks
# =====

# Execution time start
exec_time_preexec_hook() {
  exec_time_start=$(date +%s)
}

# Execution time end
exec_time_precmd_hook() {
  [[ -n $exec_time_duration ]] && unset exec_time_duration
  [[ -z $exec_time_start ]] && return
  local exec_time_stop=$(date +%s)
  exec_time_duration=$(( $exec_time_stop - $exec_time_start ))
  unset exec_time_start
}



# Async
# =====

# Are there background jobs?
function _background_jobs_async() {
  [[ $(jobs -l | wc -l) -gt 0 ]] && echo -n "black default %{%F{cyan}%}⚙"
}

# Machine backup age
function _backup_status_async {
  [[ "$PROMPT_BACKUP_AGE" == "0" ]] && echo -n "-2"

  local backup_data_dir="$PROMPT_BACKUP_DATA_DIR"
  [ -z "$backup_data_dir" ] && echo -n "-1"

  local find_command="gfind"
  command -v "$find_command" &>/dev/null || find_command="find"

  local latest_timestamp="$(gfind "$backup_data_dir" -type f -printf '%T@ %p\n' | cut -d . -f 1 | sort -bnr | head -n 1)"
  local current_timestamp="$(date +%s)"
  local diff_seconds=$(( current_timestamp - latest_timestamp ))
  local diff_days=$(( diff_seconds / 86400 ))
  echo -n "$diff_days"
}

# Git: branch/detached head, dirty status, changes compared to the remote
function _git_status_async() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0' # 
  }
  local ref dirty mode remote_changes repo_path

  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    remote_changes=$(parse_git_remote_changes "${ref/refs\/heads\/}")

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <bisect>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" <merge>"
    elif [[ -e "${repo_path}/rebase-merge/interactive" ]]; then
      mode=" <rebase -i>"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" <rebase>"
    elif [[ -e "${repo_path}/index.lock" ]]; then
      mode=" <locked>"
    fi

    local bg="green"
    local fg="$CURRENT_FG"
    if [[ -n "$mode" ]]; then
      bg="magenta"
    elif [[ -n "$dirty" ]]; then
      bg="yellow"
      fg="black"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '±'
    zstyle ':vcs_info:*' unstagedstr '∅'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "$bg $fg ${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${remote_changes}${mode}"
  fi
}

# Git changes compared to the current branch's remote (if configured).
function parse_git_remote_changes() {
  local branch="$1"
  prompt_git_ahead=0
  prompt_git_behind=0

  local merge=$(git config branch.$branch.merge 2>/dev/null)
  local remote=$(git config branch.$branch.remote 2>/dev/null)

  if [[ -n "$merge" ]] && [[ -n "$remote" ]]; then
    local ref=${merge/heads/remotes/$remote}
    local changes=${$(git rev-list --left-right $ref...HEAD 2>/dev/null | tr '\n' '-')//[^<>]/}
    prompt_git_ahead=${#${changes//</}}
    prompt_git_behind=${#${changes//>/}}
  fi

  local result=""
  [ $prompt_git_behind -gt 0 ] && result="${result} ↓${prompt_git_behind}"
  [ $prompt_git_ahead -gt 0 ] && result="${result} ↑${prompt_git_ahead}"
  print "$result"
}

# The machine environment (e.g. staging, production) as defined in a file.
function _host_environment_async() {
  local host_environment_file
  if [ -n "$HOST_ENVIRONMENT_FILE" ]; then
    host_environment_file="$HOST_ENVIRONMENT_FILE"
  elif [ -f "$HOME/.host-environment" ]; then
    host_environment_file="${HOME}/.host-environment"
  elif [ -f "/etc/.host-environment" ]; then
    host_environment_file="/etc/.host-environment"
  fi

  [ ! -f "$host_environment_file" ] && return

  local host_environment="$(cat "$host_environment_file" | sed 's/[^A-Z0-9a-z\_\-]*//')"
  [ -z "$host_environment" ] && return

  local bg=white
  local fg=black
  local normalized_host_environment="$(echo -n "$host_environment" | tr '[:upper:]' '[:lower:]')"
  [[ "$normalized_host_environment" == st* ]] && bg=yellow
  [[ "$normalized_host_environment" == pr* ]] && bg=red && fg=white && host_environment="%{%B%}$(echo "$host_environment" | tr '[:lower:]' '[:upper:]' | sed -Er 's/^PR$|^PROD$/PRODUCTION/')%{%b%}"
  echo -n "$bg" "$fg" "$host_environment"
}

function _time_async() {
  echo -n "$(date '+%X')"
}

_omz_register_handler _background_jobs_async
_omz_register_handler _backup_status_async
_omz_register_handler _git_status_async
_omz_register_handler _host_environment_async
_omz_register_handler _time_async



# Segment drawing
# ===============
# A few utility functions to make it easy and re-usable to draw segmented prompts.

CURRENT_BG='NONE'
CURRENT_FG='black'
CURRENT_PROMPT='left'

# Special Powerline characters
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline
  # changed the code points they use for their special characters. This is the
  # new code point.  If this is not working for you, you probably have an old
  # version of the Powerline-patched fonts installed. Download and install the
  # new version.  Do not submit PRs to change this unless you have reviewed the
  # Powerline code point history and have new information.
  #
  # This is defined using a Unicode escape sequence so it is unambiguously
  # readable, regardless of what font the user is viewing this source code in.
  # Do not replace the escape sequence with a single literal character.  Do not
  # change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'
  # This is the corresponding segment separator character for the right prompt.
  SEGMENT_SEPARATOR_RIGHT=$'\ue0b2'
}

# Begin a segment for the left or right prompt (the separator character is
# automatically deduced based on $CURRENT_PROMPT).  Takes two arguments,
# background and foreground. Both can be omitted, rendering default
# background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"

  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    if [[ $CURRENT_PROMPT == 'left' ]]; then
      echo -n " %{$bg%F{$CURRENT_BG}%}${SEGMENT_SEPARATOR}%{$fg%} "
    else
      echo -n " %{%K{$CURRENT_BG}%F{$1}%}${SEGMENT_SEPARATOR_RIGHT}%{$bg$fg%} "
    fi
  elif [[ $CURRENT_PROMPT == 'left' ]]; then
    echo -n "%{$bg%}%{$fg%} "
  else
    echo -n "%{%K{$CURRENT_BG}%F{$1}%}${SEGMENT_SEPARATOR_RIGHT}%{$bg$fg%} "
  fi

  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the left prompt, closing any open segments.
prompt_end_left() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# Draw a segment from async data (if available). The segment data is composed of
# the background color, the foreground color, and the segment content.
prompt_async_segment() {
  local async="$1"

  local segment_data="$_OMZ_ASYNC_OUTPUT[$async]"
  [ -z "$segment_data" ] && return

  local parts=(${(@s: :)segment_data})
  prompt_segment ${parts[1]} ${parts[2]}
  echo -n "${parts[@]:2}"
}



# Prompt components
# =================
# Each component will draw itself, and hide itself if no information needs to
# be shown.

# Machine backup age
prompt_backup() {
  local backup_age_in_days="$_OMZ_ASYNC_OUTPUT[_backup_status_async]"
  [ -z "$backup_age_in_days" ] && return

  local light_gray=245
  local backup_icon="💾"

  if [[ "$backup_age_in_days" -eq -2 ]]; then
    prompt_segment $light_gray $CURRENT_FG "$backup_icon"
  elif [[ "$backup_age_in_days" -eq -1 ]]; then
    prompt_segment red $CURRENT_FG "$backup_icon"
  elif [[ "$backup_age_in_days" -lt 2 ]]; then
    prompt_segment green $CURRENT_FG "$backup_icon"
  elif [[ "$backup_age_in_days" -lt 3 ]]; then
    prompt_segment yellow $CURRENT_FG "${backup_icon} ${backup_age_in_days}d"
  else
    prompt_segment red $CURRENT_FG "${backup_icon} ${backup_age_in_days}d"
  fi
}

# Context: [ssh] user@hostname (who am I and where am I)
prompt_context() {
  # Hide if the current user matches the configured default user.
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    [ -n "$SSH_CLIENT" ] && prompt_segment green black "SSH"
    prompt_segment black magenta "%(!.%{%F{yellow}%}.)${ssh}%n%{%F{green}%}@%{%F{magenta}%}%m"
  fi
}

# Host environment: dev/staging/production environment
prompt_host_environment() {
  prompt_async_segment _host_environment_async
}

# Current working directory
prompt_dir() {
  prompt_segment blue $CURRENT_FG '%~'
}

# Duration of the last command if it is longer than 2 seconds
prompt_duration_of_last_command() {
  if [[ $exec_time_duration -gt 2 ]]; then
    prompt_segment yellow $CURRENT_FG "${exec_time_duration}s⌛"
  fi
}

# Git: branch/detached head, dirty status, changes compared to the remote
prompt_git() {
  prompt_async_segment _git_status_async
}

# Status:
# * Was there an error?
# * Am I root?
prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘ $RETVAL"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

# Are there background jobs?
prompt_background_jobs() {
  prompt_async_segment _background_jobs_async
}

# Current time with seconds
prompt_time() {
  local time="$_OMZ_ASYNC_OUTPUT[_time_async]"
  [ -z "$time" ] && return

  local dark_gray=240
  prompt_segment $dark_gray $CURRENT_FG "$time"
}



# Main prompts
# ============

build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_background_jobs
  prompt_context
  prompt_host_environment
  prompt_dir
  prompt_git
  prompt_end_left
}

build_right_prompt() {
  CURRENT_BG='NONE'
  CURRENT_PROMPT='right'
  prompt_duration_of_last_command
  prompt_backup
  prompt_time
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec exec_time_preexec_hook
add-zsh-hook precmd exec_time_precmd_hook

PROMPT='%{%f%b%k%}$(build_prompt) '
RPROMPT='%{%f%b%k%}$(build_right_prompt) '
