# Utilities
# =========

summon () {
  if (( $# >= 1 )); then
    history 0|grep -e "$*"
  else
    history 0
  fi
}

alias smn="summon"

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
  if test -n "$max"; then
    shuf -i "0-${max}" -n 1
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
