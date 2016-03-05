# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# If set, a command name that is the name of a directory is executed
# as if it were the argument to the cd command. This option is only
# used by interactive shells.
[ "${BASH_VERSINFO[0]}" -ge 4 ] && shopt -s autocd

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  *color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*)
  ;;
esac

# Set LS_COLORS
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

function add_to_path_once() {
  if [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

function bundle_install() {
  local bundler_version bundler_1_4_0
  bundler_version=($(bundle version))
  [ -z "${bundler_version}" ] && return
  bundler_version=(${bundler_version[2]//./ })
  bundler_1_4_0=(1 4 0)

  local jobs_available=1
  for i in {0..2}; do
    if [ ${bundler_version[$i]} -gt ${bundler_1_4_0[$i]} ]; then
      break
    fi
    if [ ${bundler_version[$i]} -lt ${bundler_1_4_0[$i]} ]; then
      jobs_available=0
      break
    fi
  done
  if [ $jobs_available -eq 1 ]; then
    if [[ "$(uname)" == 'Darwin' ]]; then
      local cores_num="$(sysctl -n hw.ncpu)"
    else
      local cores_num="$(nproc)"
    fi
    bundle install --jobs=$cores_num $@
  else
    bundle install $@
  fi
}

# Add /usr/local/bin to PATH for Mac OS X
if [[ "$(uname)" == 'Darwin' ]]; then
  add_to_path_once "/usr/local/bin:/usr/local/sbin"
fi

# Load Linuxbrew
if [[ -d "$HOME/.linuxbrew" ]]; then
  add_to_path_once "$HOME/.linuxbrew/bin"
  export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
fi

# Set PATH to include user's bin if it exists
if [ -d "$HOME/bin" ]; then
  add_to_path_once "$HOME/bin"
fi

# Load autojump
if which autojump &> /dev/null; then
  if [ -f /etc/profile.d/autojump.bash ]; then
    source /etc/profile.d/autojump.bash
  elif [ -f /usr/share/autojump/autojump.bash ]; then
    source /usr/share/autojump/autojump.bash
  elif which brew &> /dev/null && [ -f `brew --prefix`/etc/autojump.sh ]; then
    source `brew --prefix`/etc/autojump.sh
  fi
elif [ -f "$HOME/.autojump/etc/profile.d/autojump.sh" ]; then
  source "$HOME/.autojump/etc/profile.d/autojump.sh"
fi

# Load fzf
if [ -f ~/.fzf.bash ]; then
  source ~/.fzf.bash

  # fshow - git commit browser
  fshow() {
    git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(green)%cr%C(reset)" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
        (grep -o '[a-f0-9]\{7\}' | head -1 |
        xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
        {}
FZF-EOF"
  }
fi

# Load chruby
if [ -e /usr/local/share/chruby/chruby.sh ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi

# Load rbenv
if [ -e "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Load pyenv
if which pyenv &> /dev/null; then
  eval "$(pyenv init -)"
  if which pyenv-virtualenv-init &> /dev/null; then
    eval "$(pyenv virtualenv-init -)"
  fi
elif [ -e "$HOME/.pyenv" ]; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  source "$HOME/.rvm/scripts/rvm"

  if [[ "$(type rvm | head -n 1)" == "rvm is a shell function" ]]; then
    # Add RVM to PATH for scripting
    PATH=$PATH:$HOME/.rvm/bin
    export rvmsudo_secure_path=1

    # Use right RVM gemset when using tmux
    if [[ "$TMUX" != "" ]]; then
      rvm use default
      cd ..;cd -
    fi
  fi
fi

# Set GOPATH for Go
if which go &> /dev/null; then
  [ -d "$HOME/.go" ] || mkdir "$HOME/.go"
  export GOPATH="$HOME/.go"
  export PATH="$PATH:$GOPATH/bin"
fi

# Check if reboot is required for Ubuntu
if [ -f /usr/lib/update-notifier/update-motd-reboot-required ]; then
  function reboot-required() {
    /usr/lib/update-notifier/update-motd-reboot-required
  }
fi

# Enable keychain
if which keychain &> /dev/null; then
  eval `keychain --eval --quiet --agents ssh id_rsa`
fi

# Unset local functions
unset -f add_to_path_once

# Define aliases
# Enable color support
ls --color -d . &> /dev/null && alias ls='ls --color=auto' || alias ls='ls -G'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Some more basic aliases
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'
alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -lah'
alias md='mkdir -p'
alias rd='rmdir'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# Bundler
alias be='bundle exec'
alias bi='bundle_install'
alias bu='bundle update'

# Git
alias g='git'
alias ga='git add'
alias gapa='git add --patch'
alias gb='git branch'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcb='git checkout -b'
alias gcm='git checkout master'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gdca='git diff --cached'
alias gf='git fetch'
alias ggpush='git push origin HEAD'
alias gl='git pull'
alias glg='git log --graph --pretty=format:"%C(yellow)%h %C(blue)%ar %C(green)%an%C(reset) %s%C(auto)%d"'
alias glga='git log --graph --pretty=format:"%C(yellow)%h %C(blue)%ar %C(green)%an%C(reset) %s%C(auto)%d" --all'
alias glgg='git log --graph --decorate'
alias glgga='git log --graph --decorate --all'
alias gp='git push'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grup='git remote update'
alias gst='git status'
alias gsta='git stash'
alias gstd='git stash drop'
alias gstp='git stash pop'

# Vim
alias v='vim'
alias vi='vim'

alias ruby-server='ruby -run -ehttpd . -p8000'

# Source local bashrc
if [ -f "$HOME/.bashrc.local" ]; then
  source "$HOME/.bashrc.local"
fi
