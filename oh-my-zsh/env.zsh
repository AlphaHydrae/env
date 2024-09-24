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
