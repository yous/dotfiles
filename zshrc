# See http://zsh.sourceforge.net/Doc/Release/Options.html.

# Changing Directories
setopt auto_cd

# Completion
setopt always_to_end
setopt auto_menu
setopt complete_in_word
unsetopt list_beep
unsetopt menu_complete

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Set LS_COLORS
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
if [ -z "$LS_COLORS" ]; then
  zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
else
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# History
setopt append_history
setopt hist_ignore_all_dups

[ -z "$HISTFILE" ] && HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Input/Output
unsetopt flow_control

# Make the $path array have unique values.
typeset -U path

function add_to_path_once()
{
  path=("$1" $path)
}

function bundle_install()
{
  local bundler_version bundler_1_4_0
  bundler_version=($(bundle version))
  bundler_version=(${(s/./)bundler_version[3]})
  bundler_1_4_0=(1 4 0)

  local jobs_available=1
  for i in {1..3}; do
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

# Load zplug
source $HOME/.zplug/zplug

# Let zplug manage zplug
zplug "b4b4r07/zplug"
# Additional completion definitions for Zsh
zplug "zsh-users/zsh-completions"
# Load the theme.
zplug "yous/lime"
# Syntax highlighting bundle. zsh-syntax-highlighting must be loaded after
# excuting compinit command and sourcing other plugins.
zplug "zsh-users/zsh-syntax-highlighting", nice:10

# Install plugins if there are plugins that have not been installed
if ! zplug check; then
  zplug install
fi
# Then, source plugins and add commands to $PATH
zplug load

# Set PATH to include user's bin if it exists
if [ -d "$HOME/bin" ]; then
  add_to_path_once "$HOME/bin"
fi

# Load autojump
if which autojump &> /dev/null; then
  if [ -f /etc/profile.d/autojump.zsh ]; then
    source /etc/profile.d/autojump.zsh
  elif [ -f /usr/share/autojump/autojump.zsh ]; then
    source /usr/share/autojump/autojump.zsh
  elif which brew &> /dev/null && [ -f `brew --prefix`/etc/autojump.sh ]; then
    source `brew --prefix`/etc/autojump.sh
  fi
fi

# Load fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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

# Oh My Zsh sets custom LSCOLORS from lib/theme-and-appearance.zsh
# This is default LSCOLORS from the man page of ls
[[ "$(uname)" == 'Darwin' ]] && export LSCOLORS=exfxcxdxbxegedabagacad

# Check if reboot is required for Ubuntu
if [ -f /usr/lib/update-notifier/update-motd-reboot-required ]; then
  function reboot-required()
  {
    /usr/lib/update-notifier/update-motd-reboot-required
  }
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
alias git='noglob git'
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
alias gl='git pull'
alias glg='git log --graph --pretty=format:"%Cred%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"'
alias glga='git log --graph --pretty=format:"%Cred%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --all'
alias glgg='git log --graph --decorate'
alias glgga='git log --graph --decorate --all'
alias gp='git push'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias gst='git status'
alias gsta='git stash'
alias gstd='git stash drop'
alias gstp='git stash pop'

# Vim
alias v='vim'
alias vi='vim'

alias ruby-server='ruby -run -ehttpd . -p8000'

# Source local zshrc
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
