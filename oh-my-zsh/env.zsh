# Shared ZSH environment initialization:
#
# - Keep shell environment variables and runtime hints consistent across sessions.
# - Provide nested-tmux SSH hints consumed by tmux auto-detection scripts.

ensure_tmux_term() {
	if [[ -n "$TMUX" && -n "$TMUX_PANE" ]]; then
		export TERM="tmux-256color"
	fi
}

# Keep TERM aligned with tmux for commands launched from existing shells,
# without requiring an ssh wrapper.
ensure_tmux_term
typeset -ga precmd_functions
if (( ${precmd_functions[(I)ensure_tmux_term]} == 0 )); then
	precmd_functions+=(ensure_tmux_term)
fi

# Propagate explicit nested hint for remote shells reached from tmux terminals.
# Mark remote SSH shells that originate from a tmux terminal so remote tmux
# can reliably auto-switch to passive-inner without broad TERM heuristics.
if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" ]]; then
	if [[ "$TERM" == tmux* || "$TERM" == screen* ]]; then
		export TMUX_NESTED_HINT="1"
	else
		unset TMUX_NESTED_HINT
	fi
fi

# Language environment
export LC_ALL="en_US.utf-8"
export LANG="$LC_ALL"

# Preferred editor
export EDITOR=vim

# Editor for projects
export PROJECT_EDITOR="vim -c NERDTree"

# GPG
export GPG_TTY=$(tty)

# Disable Ansible usage of cowsay
# See https://github.com/ansible/ansible/issues/68571
export ANSIBLE_NOCOWS=1

# Increase the maximum number of open file descriptors
ulimit -n 1024
