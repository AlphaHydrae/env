# Custom shell functions.

# tmux
# ====

function xide() {
  test -f .tmuxinator.yml && tmuxinator || tmux
}

# SSH and immediately attach/create a remote tmux session in the current path.
function sshx() {
  if (( $# < 1 )); then
    echo "Usage: sshx <ssh-target> [ssh-args...]" >&2
    return 1
  fi

  local target="$1"
  shift

  # Explicitly pass nested hint so the remote tmux can switch to passive-inner.
  if [ -n "$TMUX" ]; then
    ssh -t "$target" "$@" 'TMUX_NESTED_HINT=1 tmux new-session -A -s main'
  else
    ssh -t "$target" "$@" 'tmux new-session -A -s main'
  fi
}

# Reload Tmux configuration file.
function tmux-reload() {
  tmux source-file ~/.tmux.conf
}

# Zellij
# ======

function zide() {
  test -f .zellij.kdl && zellij --layout .zellij.kdl || zellij
}

# Utilities
# =========

summon () {
  if (( $# >= 1 )); then
    history 0|grep -e "$*"
  else
    history 0
  fi
}

psef () {
  if (( $# >= 1 )); then
    ps -ef|grep "$*"
  else
    ps -ef
  fi
}

td () {
  for file in $@; do
    mkdir -p "$(dirname "$file")"
    touch "$file"
  done
}

# PDF utilities
# =============

function compress-pdf() {
  INPUT="$1"
  OUTPUT="$2"

  if [ -z "$INPUT" ]; then
    echo "First argument must be the PDF file to compress" >&2
  elif [ -z "$OUTPUT" ]; then
    echo "Second argument must be the target file" >&2
  else
    gs -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH -dPDFSETTINGS=/ebook -dCompatibilityLevel=1.4 -sOutputFile="$OUTPUT" "$INPUT"
  fi
}

# Random generation functions
# ===========================

function random-hex() {
  LENGTH=$1
  if [ -z $LENGTH ]; then
    LENGTH=32
  fi

  echo -n "$(openssl rand -hex $LENGTH)"
}

function random-base64() {
  BYTES=$1
  if [ -z $BYTES ]; then
    BYTES=100
  fi

  echo -n "$(dd if=/dev/random bs=$BYTES count=1 2>/dev/null | base64)"
}

function random-uuid() {
  if command -v uuidgen &>/dev/null; then
    uuidgen | tr "[:upper:]" "[:lower:]" | tr -d '\n'
  elif command -v ruby &>/dev/null; then
    ruby -e "require 'securerandom'; print SecureRandom.uuid"
  else
    >&2 echo "random-uuid requires either uuidgen or ruby to be installed"
    return 1
  fi
}

function random-alphanumeric() {
  LENGTH=$1
  if [ -z $LENGTH ]; then
    LENGTH=50
  fi

  echo -n "$(env LC_CTYPE=C LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w $LENGTH | head -n 1)"
}

function random-number() {
  local max="$1"

  # Keep a deterministic range contract when a max value is provided.
  if test -n "$max"; then
    shuf -i "0-${max}" -n 1 | tr -d '\n'
  else
    sh -c "RANDOM=\$\$ printf \$RANDOM"
  fi
}

function random-password() {
  LENGTH=$1
  if [ -z $LENGTH ]; then
    LENGTH=50
  fi

  echo -n "$(env LC_CTYPE=C LC_ALL=C tr -dc 'A-Za-z0-9!#$%&()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c $LENGTH)"
}

function random-port() {
  local n="$(random-number 65534)"
  echo -n "$(($n + 1))"
}


# Vagrant configuration & utilities
# =================================
# https://www.vagrantup.com

function vs () {
  vagrant ssh -c "cd /vagrant && $*"
}

function vsu () {
  vagrant ssh -c "sudo su -" "$@"
}

export VAGRANT_DISABLE_VBOXSYMLINKCREATE=1
