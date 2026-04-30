#!/usr/bin/env bash

set_mode_script="$(dirname "$0")/set-nested-mode.sh"
debug_log="${TMPDIR:-/tmp}/tmux-nested-debug.log"
debug_enabled="$(tmux show-options -gv @nested_debug 2>/dev/null || echo 0)"
auto_over_ssh="$(tmux show-options -gv @nested_auto_over_ssh 2>/dev/null || echo 1)"

source_hint="${1:-manual}"
hook_client_term="${2:-}"
hook_session_name="${3:-}"
term_env="${TERM:-}"
ssh_hint="${SSH_TTY:-${SSH_CONNECTION:-}}"
nested_hint="${TMUX_NESTED_HINT:-0}"

log_debug() {
  if [[ "$debug_enabled" != "1" ]]; then
    return
  fi

  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '%s | %s\n' "$ts" "$*" >> "$debug_log"
}

current_mode="$(tmux show-options -gv @nested_mode 2>/dev/null || echo unknown)"
current_role="$(tmux show-options -gv @nested_role 2>/dev/null || echo unknown)"

# Resolve the best available terminal identity for the currently active client.
client_term="$(tmux display-message -p '#{client_termname}' 2>/dev/null)"

if [[ -n "$hook_client_term" ]]; then
  client_term="$hook_client_term"
fi

if [[ -z "$client_term" || "$client_term" == "" ]]; then
  client_term="$term_env"
fi

clients_snapshot="$(tmux list-clients -F '#{client_tty}|#{client_termname}|#{session_name}' 2>/dev/null | tr '\n' ';')"

log_debug "source=$source_hint hook_term=${hook_client_term:-<empty>} term=$client_term term_env=${term_env:-<empty>} ssh=${ssh_hint:-<empty>} hint=${nested_hint:-<empty>} auto_over_ssh=${auto_over_ssh:-<empty>} session=${hook_session_name:-<empty>} before_mode=$current_mode before_role=$current_role clients=${clients_snapshot:-<none>}"

is_nested=0
case "$client_term" in
  tmux*|screen*)
    is_nested=1
    ;;
esac

# Explicit hint from sshx / wrappers always marks nested sessions.
if [[ "$is_nested" -eq 0 && "$nested_hint" == "1" ]]; then
  is_nested=1
fi

# Some SSH hops report xterm client_termname even when launched from tmux.
# Treat SSH + tmux-like TERM as nested when enabled.
if [[ "$is_nested" -eq 0 ]]; then
  if [[ "$source_hint" == "startup" ]]; then
    case "$term_env" in
      tmux*|screen*)
        if [[ -n "$ssh_hint" && "$auto_over_ssh" == "1" ]]; then
          is_nested=1
        fi
        ;;
    esac
  fi
fi

if [[ "$is_nested" -eq 1 ]]; then
  # Nested tmux should start in passive mode and hide the inner clock.
  bash "$set_mode_script" passive-inner inner
  current_mode="$(tmux show-options -gv @nested_mode 2>/dev/null || echo unknown)"
  current_role="$(tmux show-options -gv @nested_role 2>/dev/null || echo unknown)"
  log_debug "action=apply-passive-inner after_mode=$current_mode after_role=$current_role"
else
  # Ensure plain SSH / local sessions don't inherit stale passive-inner state
  # from a previously nested attach on the same tmux server.
  if [[ "$current_mode" != "active" || "$current_role" != "outer" ]]; then
    bash "$set_mode_script" active outer
    current_mode="$(tmux show-options -gv @nested_mode 2>/dev/null || echo unknown)"
    current_role="$(tmux show-options -gv @nested_role 2>/dev/null || echo unknown)"
    log_debug "action=apply-active-outer after_mode=$current_mode after_role=$current_role"
  else
    log_debug "action=skip reason=already-active-outer"
  fi
fi
