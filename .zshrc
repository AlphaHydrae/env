#!/bin/zsh
#
# .zshrc
#
# by AlphaHydrae <hydrae.alpha@gmail.com>
# modified from the version of Kuon <kuon@goyman.com>
# inspired of the version of Adam Spiers <adam@spiers.net> but with heavy modifications
#
#

# if for rvm (see bottom)
if [ ! -n "$INHERIT_ENV" ]; then

  [[ -n "$ZSH_PROFILE_RC" ]] && which zmodload >&/dev/null && zmodload zsh/zprof

  # Zsh options
  setopt            \
    C_BASES        \
    NO_all_export      \
    always_last_prompt    \
    NO_always_to_end    \
    append_history      \
    auto_cd          \
    auto_list        \
    auto_menu        \
    NO_auto_name_dirs    \
    auto_param_keys      \
    auto_param_slash    \
    auto_pushd        \
    auto_remove_slash    \
    NO_auto_resume      \
    bad_pattern        \
    bang_hist        \
    NO_beep          \
    NO_brace_ccl      \
    correct_all        \
    NO_bsd_echo        \
    cdable_vars        \
    NO_chase_links      \
    NO_clobber        \
    complete_aliases    \
    complete_in_word    \
    NO_correct        \
    correct_all        \
    csh_junkie_history    \
    NO_csh_junkie_loops    \
    NO_csh_junkie_quotes  \
    NO_csh_null_glob    \
    equals          \
    extended_glob      \
    extended_history    \
    function_argzero    \
    glob          \
    NO_glob_assign      \
    glob_complete      \
    NO_glob_dots      \
    glob_subst        \
    hash_cmds        \
    hash_dirs        \
    hash_list_all      \
    hist_allow_clobber    \
    hist_beep        \
    hist_ignore_dups    \
    hist_ignore_space    \
    NO_hist_no_store    \
    hist_verify        \
    NO_hup          \
    NO_ignore_braces    \
    NO_ignore_eof      \
    interactive_comments  \
    ksh_glob        \
    NO_list_ambiguous    \
    NO_list_beep      \
    list_types        \
    long_list_jobs      \
    magic_equal_subst    \
    NO_mail_warning      \
    NO_mark_dirs      \
    NO_menu_complete    \
    multios          \
    nomatch          \
    notify          \
    NO_null_glob      \
    numeric_glob_sort    \
    NO_overstrike      \
    path_dirs        \
    posix_builtins      \
    NO_print_exit_value    \
    NO_prompt_cr      \
    prompt_subst      \
    pushd_ignore_dups    \
    NO_pushd_minus      \
    pushd_silent      \
    pushd_to_home      \
    rc_expand_param      \
    NO_rc_quotes      \
    NO_rm_star_silent    \
    NO_sh_file_expansion  \
    sh_option_letters    \
    short_loops        \
    sh_word_split      \
    NO_single_line_zle    \
    NO_sun_keyboard_hack  \
    unset          \
    NO_verbose        \
    zle            \
    hist_expire_dups_first  \
    hist_ignore_all_dups  \
    NO_hist_no_functions  \
    NO_hist_save_no_dups  \
    inc_append_history    \
    list_packed        \
    NO_rm_star_wait      \
    hist_reduce_blanks


  WORDCHARS=''

  HISTFILE=~/.zshhistory
  HISTSIZE=300000
  SAVEHIST=300000

  # Big completion listing
  LISTMAX=1000

  # Other Users
  LOGCHECK=60
  WATCHFMT="[%B%t%b] %B%n%b has %a %B%l%b from %B%M%b"

  # Auto logout
  TMOUT=1800

  local _find_promptinit
  _find_promptinit=( $^fpath/promptinit(N) )
  if (( $#_find_promptinit >= 1 )) && [[ -r $_find_promptinit[1] ]]; then

    autoload -U promptinit
    promptinit

    PS4="trace %N:%i> "
    #RPS1="$bold_colour$bg_red              $reset_colour"

    # Default prompt style
    adam2_colors=( white cyan cyan green )

    if [[ -r $zdotdir/.zsh_prompt ]]; then
      . $zdotdir/.zsh_prompt
    fi

    if [[ -r /proc/$PPID/cmdline ]] &&
         egrep -q 'watchlogs|kates|nexus|vga' /proc/$PPID/cmdline;
    then
      # probably OK for fancy graphic prompt
      if [[ "`prompt -h adam2`" == *8bit* ]]; then
        prompt adam2 8bit $adam2_colors
      else
        prompt adam2 $adam2_colors
      fi
    else
      if [[ "`prompt -h adam2`" == *plain* ]]; then
        prompt adam2 plain $adam2_colors
      else
        prompt adam2 $adam2_colors
      fi
    fi

    if [[ $TERM == tgtelnet ]]; then
      prompt off
    fi
  else
    PS1='%n@%m %B%3~%b %# '
  fi

  # Advanced completion
  autoload -U compinit
  compinit -C # don't perform security check

  # zstyle ':completion:*' completer \
  #   _complete _prefix _approximate:-one _ignored \
  #   _complete:-extended _approximate:-four
  zstyle ':completion:*' completer _complete _prefix _ignored _complete:-extended

  zstyle ':completion::prefix-1:*' completer _complete
  zstyle ':completion:incremental:*' completer _complete _correct
  zstyle ':completion:predict:*' completer _complete

  zstyle ':completion:*:approximate-one:*'  max-errors 1
  zstyle ':completion:*:approximate-four:*' max-errors 4

  # e.g. f-1.j<TAB> would complete to foo-123.jpeg
  zstyle ':completion:*:complete-extended:*' \
    matcher 'r:|[.,_-]=* r:|=*'

  zstyle ':completion:*' menu yes select interactive
  #zstyle ':completion:*' menu yes=long select=long interactive
  #zstyle ':completion:*' menu yes=10 select=10 interactive
  zstyle ':completion::complete:*' use-cache 1
  zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST
  zstyle ':completion:*' expand 'yes'
  zstyle ':completion:*' squeeze-slashes 'yes'
  zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~' # No backup file

  # Don't complete uninteresting users
  zstyle ':completion:*:*:*:users' ignored-patterns \
    adm apache bin daemon games gdm halt ident junkbust lp mail mailnull \
    named news nfsnobody nobody nscd ntp operator pcap postgres radvd \
    rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs

  # ... unless we really want to.
  zstyle '*' single-ignored show

  # Separate matches into groups
  zstyle ':completion:*:matches' group 'yes'

  # Describe each match group.
  zstyle ':completion:*:descriptions' format "%B---- %d%b"

  # Messages/warnings format
  zstyle ':completion:*:messages' format '%B%U---- %d%u%b' 
  zstyle ':completion:*:warnings' format '%B%U---- no match for: %d%u%b'

  # Describe options in full
  zstyle ':completion:*:options' description 'yes'
  zstyle ':completion:*:options' auto-description '%d'


  # When completing inside array or association subscripts, the array
  # elements are more useful than parameters so complete them first:
  zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
  zstyle ':completion:*:*:*:*:processes' menu yes select
  zstyle ':completion:*:*:*:*:processes' force-list always
  zstyle ':completion:*:history-words' stop yes
  zstyle ':completion:*:history-words' remove-all-dups yes
  zstyle ':completion:*:history-words' list false
  zstyle ':completion:*:history-words' menu yes

  _my_extended_wordchars='*?_-.[]~=&;!#$%^(){}<>:@,\\'
  _my_extended_wordchars_space="${_my_extended_wordchars} "
  _my_extended_wordchars_slash="${_my_extended_wordchars}/"

  # is the current position \-quoted ?
  is_backslash_quoted () {
      test "${BUFFER[$CURSOR-1,CURSOR-1]}" = "\\"
  }

  unquote-forward-word () {
      while is_backslash_quoted
        do zle .forward-word
      done
  }

  unquote-backward-word () {
      while is_backslash_quoted
        do zle .backward-word
      done
  }

  backward-to-space () {
      local WORDCHARS="${_my_extended_wordchars_slash}"
      zle .backward-word
      unquote-backward-word
  }

  forward-to-space () {
       local WORDCHARS="${_my_extended_wordchars_slash}"
       zle .forward-word
       unquote-forward-word
  }

  backward-to-/ () {
      local WORDCHARS="${_my_extended_wordchars}"
      zle .backward-word
      unquote-backward-word
  }

  forward-to-/ () {
       local WORDCHARS="${_my_extended_wordchars}"
       zle .forward-word
       unquote-forward-word
  }

  # Create new user-defined widgets pointing to eponymous functions.
  zle -N backward-to-space
  zle -N forward-to-space
  zle -N backward-to-/
  zle -N forward-to-/

  # autoloaded
  zle -N kill-region-or-backward-word
  zle -N kill-region-or-backward-big-word

  kill-big-word () {
      local WORDCHARS="${_my_extended_wordchars_slash}"
      zle .kill-word
  }

  zle -N kill-big-word
  zle -N transpose-big-words
  zle -N magic-forward-char
  zle -N magic-forward-word
  zle -N incremental-complete-word
  autoload zrecompile


  alias which >&/dev/null && unalias which
  alias wh=where
  alias run-help >&/dev/null && unalias run-help
  autoload run-help
  autoload zcalc # Calculator

  bash () {
    NO_SWITCH="yes" command bash "$@"
  }

  restart () {
    if jobs | grep . >/dev/null; then
      echo "Jobs running; won't restart." >&2
    else
      exec $SHELL $SHELL_ARGS "$@"
    fi
  }

  profile () {
    ZSH_PROFILE_RC=1 $SHELL "$@"
  }

  reload () {
    if [[ "$#*" -eq 0 ]]; then
      . $zdotdir/.zshrc
    else
      local fn
      for fn in "$@"; do
        unfunction $fn
        autoload -U $fn
      done
    fi
  }
  compdef _functions reload

  # ls
  if [[ $( uname ) == 'Darwin' ]]; then
    alias ls='command ls -Gv'
  else
    alias ls='command ls --color=auto'
  fi


  # jeez I'm lazy ...
  alias l='ls -lh'
  alias ll='ls -l'
  alias la='ls -lha'
  alias lla='ls -la'
  alias lsa='ls -ah'
  alias lsd='ls -d'
  alias lsh='ls -dh .*'
  alias lsr='ls -Rh'
  alias ld='ls -ldh'
  alias lt='ls -lth'
  alias llt='ls -lt'
  alias lrt='ls -lrth'
  alias llrt='ls -lrt'
  alias lart='ls -larth'
  alias llart='ls -lart'
  alias lr='ls -lRh'
  alias llr='ls -lR'
  alias lsL='ls -L'
  alias lL='ls -Ll'
  alias lS='ls -lSh'
  alias lrS='ls -lrSh'
  alias llS='ls -lS'
  alias llrS='ls -lrS'
  alias sl=ls

  alias -g ...=../..
  alias -g ....=../../..
  alias -g .....=../../../..
  alias -g ......=../../../../..
  alias cd..='cd ..'
  alias cd...='cd ../..'
  alias cd....='cd ../../..'
  alias cd.....='cd ../../../..'
  # blegh
  alias ..='cd ..'
  alias ../..='cd ../..'
  alias ../../..='cd ../../..'
  alias ../../../..='cd ../../../..'
  alias ../../../../..='cd ../../../../..'

  alias cd/='cd /'

  alias 1='cd -'
  alias 2='cd +2'
  alias 3='cd +3'
  alias 4='cd +4'
  alias 5='cd +5'
  alias 6='cd +6'
  alias 7='cd +7'
  alias 8='cd +8'
  alias 9='cd +9'

  # Sweet trick from zshwiki.org :-)
  #cd () {
  #  if (( $# != 1 )); then
  #    builtin cd "$@"
  #    return
  #  fi
  #
  #  if [[ -f "$1" ]]; then
  #    builtin cd "$1:h"
  #  else
  #    builtin cd "$1"
  #  fi
  #}

  #z () {
  #  cd ~/"$1"
  #}

  alias md='mkdir -p'
  alias rd=rmdir

  alias d='dirs -v'

  po () {
    popd "$@"
    dirs -v
  }


  autoload zmv # Very cool, learn it
  alias mmv='noglob zmv -W'
  alias j='jobs -l'
  alias dn=disown
  alias h='history -$LINES'
  alias hh='history 1'
  alias ts=typeset
  compdef _typeset ts
  alias cls='clear'
  alias term='echo $TERM'



  which cx >&/dev/null || cx () { }

  if [[ "$TERM" == ([Ex]term*|screen*) ]]; then
    # Could also look at /proc/$PPID/cmdline ...
    cx
  fi

  alias sc=screen

  compdef _users lh

  alias f='finger -m'
  compdef _finger f

  # su changes window title, even if we're not a login shell
  su () {
    command su "$@"
    cx
  }

  # log files watching (auto refresh)
  alias tf='less +F'
  alias tfs='less -S +F'

  alias bz=bzip2
  alias buz=bunzip2

  # Keys
  bindkey -v # vim key bindings
  bindkey '^d' delete-char # delete key
  bindkey '^?' backward-delete-char # backspace key
  bindkey "^[[3~" delete-char # delete key for iterm 2
  bindkey "^[3;5~" delete-char # delete key for iterm 2
  bindkey '^R' history-incremental-search-backward # history search
  bindkey '^T' history-incremental-search-forward

  # No autologout in screen and such
  if [[ "${TERM}" == ([Ex]term*|dtterm|screen*) ]]; then
    unset TMOUT
  fi

  which check_hist_size >&/dev/null && check_hist_size

  #
  # Additions by AlphaHydrae
  #

  # Disable autocorrect
  alias cap='nocorrect cap'
  alias man='nocorrect man'
  alias mkdir='nocorrect mkdir'
  alias mv='nocorrect mv'
  alias rj='nocorrect rj'
  alias git='nocorrect git'
  alias hub='nocorrect hub'
  alias ionic='nocorrect ionic'
  alias rvm='nocorrect rvm'
  alias vim='nocorrect vim'
  alias rspec='nocorrect rspec'
  alias bundle='nocorrect bundle'
  alias grunt='nocorrect grunt'
  alias vagrant='nocorrect vagrant'
  alias rake='nocorrect rake'
  alias rbenv='nocorrect rbenv'

  # Functions
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

  svn_add_new () {
    svn status|grep "?"|sed 's/\? *//g;/^tmp/d;/^log/d'|xargs svn add
  }

  svn_delete_missing () {
    svn status|grep "\!"|sed 's/\! *//g;/^tmp/d;/^log/d'|xargs svn delete
  }

  # color diffs for SVN 
  function svncdiff () {
    if [ "$1" != "" ]; then
      svn diff $@ | colordiff;
    else
      svn diff | colordiff;
    fi
  }

  alias vcurl="curl -vvv -w '\n\nTotal time: %{time_total}'"

  export LC_ALL="en_US.utf-8"
  export LANG="$LC_ALL"

  [ -r ~/.zshprivate ] && source ~/.zshprivate
  [ -f ~/.zshconfig ] && source ~/.zshconfig
  which direnv &>/dev/null && eval "$(direnv hook zsh)"

  # Aliases
  alias smn="summon"
  alias vi="vim"
  alias less="less -R"
  alias pg="playground"
  alias vimtree="vim -c NERDTree"
  alias vimt="vimtree"
  alias vlc="open -n /Applications/VLC.app"
  alias pub="cat ~/.ssh/id_rsa.pub"
  alias ogc="open -a Google\ Chrome"
  hash hub 2>/dev/null && alias git="hub"

  # Docker Aliases
  alias docker-rmfa="docker rm -f \$\(docker ps -a -q\)"
  alias docker-runrm="docker run --rm -it"

  # Vagrant Utilities
  function vs () {
    vagrant ssh -c "cd /vagrant && $*"
  }

  # PDF Utilities
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

  # Random Utilities
  function random-hex () {
    LENGTH=$1
    if [ -z $LENGTH ]; then
      LENGTH=32
    fi

    echo -n "$(openssl rand -hex $LENGTH)"
  }

  function random-base64 () {
    BYTES=$1
    if [ -z $BYTES ]; then
      BYTES=100
    fi

    echo -n "$(dd if=/dev/random bs=$BYTES count=1 2>/dev/null | base64)"
  }

  function random-uuid () {
    ruby -e "require 'securerandom'; print SecureRandom.uuid"
  }

# if for rvm
fi

# Vim for projects
export PROJECT_EDITOR="vim -c NERDTree"

# Scide
export SCIDE_AUTO=true

# Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# rbenv
export PATH=$HOME/.rbenv/shims:$PATH

# nodenv
if [ -s /usr/local/bin/nodenv ]; then
  eval "$(/usr/local/bin/nodenv init -)"
else
  export PATH=$HOME/.nodenv/bin:$HOME/.nodenv/shims:$PATH
fi

alias nodenv='nocorrect nodenv'

# Homebrew sbin
export PATH="$PATH:/usr/local/sbin"

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
PATH=$PATH:$HOME/.rvm/bin
