# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  # See https://github.com/microsoft/WSL/issues/352
  if [[ "$(umask)" = *'000' ]]; then
    if [ -e /etc/login.defs ] && grep -q '^[[:space:]]*USERGROUPS_ENAB[[:space:]]\{1,\}yes' /etc/login.defs; then
      umask 002
    else
      umask 022
    fi
  fi
fi

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

# Load git-prompt.sh
git_prompt_loaded=yes
if [ -f /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
  source /usr/local/etc/bash_completion.d/git-prompt.sh
elif [ -f /usr/share/git/completion/git-prompt.sh ]; then
  source /usr/share/git/completion/git-prompt.sh
elif [ -f /etc/bash_completion.d/git-prompt ]; then
  source /etc/bash_completion.d/git-prompt
elif [ -f /etc/bash_completion.d/git ]; then
  source /etc/bash_completion.d/git
else
  git_prompt_loaded=
fi

if [ "$git_prompt_loaded" = "yes" ]; then
  case "$(uname)" in
    Darwin | Linux)
      GIT_PS1_SHOWDIRTYSTATE=true
      GIT_PS1_STATESEPARATOR=""
      ;;
  esac
fi

if [ "$color_prompt" = yes ]; then
  if [[ "$TERM" = *"256color" ]]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;109m\]\u\[\033[00m\] \[\033[38;5;143m\]\w\[\033[00m\]'
    if [ "$git_prompt_loaded" = "yes" ]; then
      PS1="$PS1"'\[\033[38;5;109m\]$(__git_ps1 " %s")\[\033[00m\]'
    fi
    PS1="$PS1 \$ "
  else
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;36m\]\u\[\033[00m\] \[\033[01;32m\]\w\[\033[00m\]'
    if [ "$git_prompt_loaded" = "yes" ]; then
      PS1="$PS1"'\[\033[01;36m\]$(__git_ps1 " %s")\[\033[00m\]'
    fi
    PS1="$PS1 \$ "
  fi
else
  PS1='${debian_chroot:+($debian_chroot)}\u \w'
  if [ "$git_prompt_loaded" = "yes" ]; then
    PS1="$PS1"'$(__git_ps1 " %s")'
  fi
  PS1="$PS1 \$ "
fi
unset color_prompt force_color_prompt git_prompt_loaded

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
  if [ -r ~/.dircolors ]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

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

if command -v brew >/dev/null; then
  BREW_PREFIX="$(brew --prefix)"
fi

# Load z
if [ -f "$HOME/.z.sh" ]; then
  source "$HOME/.z.sh"
elif [ -n "$BREW_PREFIX" ]; then
  if [ -f "$BREW_PREFIX/etc/profile.d/z.sh" ]; then
    source "$BREW_PREFIX/etc/profile.d/z.sh"
  fi
fi

# Load autojump
if command -v autojump >/dev/null; then
  if [ -f "$HOME/.autojump/etc/profile.d/autojump.sh" ]; then
    source "$HOME/.autojump/etc/profile.d/autojump.sh"
  elif [ -f /etc/profile.d/autojump.bash ]; then
    source /etc/profile.d/autojump.bash
  elif [ -f /usr/share/autojump/autojump.bash ]; then
    source /usr/share/autojump/autojump.bash
  elif [ -n "$BREW_PREFIX" ]; then
    if [ -f "$BREW_PREFIX/etc/autojump.sh" ]; then
      source "$BREW_PREFIX/etc/autojump.sh"
    fi
  fi
elif [ -f "$HOME/.autojump/etc/profile.d/autojump.sh" ]; then
  source "$HOME/.autojump/etc/profile.d/autojump.sh"
fi

# Load fzf
if [ -f ~/.fzf.bash ]; then
  export FZF_DEFAULT_OPTS='--bind ctrl-f:page-down,ctrl-b:page-up'
  source ~/.fzf.bash

  # fshow - git commit browser
  fshow() {
    git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(green)%cr%C(reset)" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                 xargs -I % sh -c 'git show --color=always %'" \
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
elif [ -n "$BREW_PREFIX" ]; then
  if [ -e "$BREW_PREFIX/opt/chruby/share/chruby/chruby.sh" ]; then
    source "$BREW_PREFIX/opt/chruby/share/chruby/chruby.sh"
    source "$BREW_PREFIX/opt/chruby/share/chruby/auto.sh"
  fi
fi

# Load rbenv
if command -v rbenv >/dev/null || [ -e "$HOME/.rbenv" ]; then
  eval "$(rbenv init - bash)"
fi

# Load pyenv
if command -v pyenv >/dev/null; then
  eval "$(pyenv init - bash)"
  if command -v pyenv-virtualenv-init >/dev/null; then
    eval "$(pyenv virtualenv-init - bash)"
  fi
elif [ -e "$HOME/.pyenv" ]; then
  eval "$(pyenv init - bash)"
  if [ -e "$HOME/.pyenv/plugins/pyenv-virtualenv" ]; then
    eval "$(pyenv virtualenv-init - bash)"
  fi
fi

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  source "$HOME/.rvm/scripts/rvm"

  if [[ "$(type rvm | head -n 1)" == "rvm is a shell function" ]]; then
    # Add RVM to PATH for scripting
    case ":$PATH:" in
      *":$HOME/.rvm/bin:"*)
        ;;
      *)
        export PATH="$PATH:$HOME/.rvm/bin"
    esac
    export rvmsudo_secure_path=1

    # Use right RVM gemset when using tmux
    if [ -n "$TMUX" ]; then
      rvm use default
      pushd -n ..
      popd -n
    fi
  fi
fi

# Enable keychain
if command -v keychain >/dev/null; then
  KEY=''
  if [ -f "$HOME/.ssh/id_ed25519" ]; then
    KEY='id_ed25519'
  elif [ -f "$HOME/.ssh/id_rsa" ]; then
    KEY='id_rsa'
  fi
  if [ -n "$KEY" ]; then
    if [ "$(uname)" = 'Darwin' ]; then
      eval `keychain --eval --quiet --agents ssh --inherit any $KEY`
    else
      eval `keychain --eval --quiet --agents ssh $KEY`
    fi
  fi
  unset KEY
fi

# Unset local functions and variables
unset BREW_PREFIX

# Define aliases
if [ -f "$HOME/.aliases" ]; then
  source "$HOME/.aliases"
fi

# Source local bashrc
if [ -f "$HOME/.bashrc.local" ]; then
  source "$HOME/.bashrc.local"
fi
