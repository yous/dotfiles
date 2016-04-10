# Make the $path array have unique values.
typeset -U path

function add_to_path_once() {
  path=("$1" $path)
}

function bundle_install() {
  local bundler_version bundler_1_4_0
  bundler_version=($(bundle version))
  [ -z "${bundler_version}" ] && return
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

# Completions for Homebrew
if command -v brew &> /dev/null; then
  if [ ! -f `brew --prefix`/share/zsh/site-functions/_brew ]; then
    mkdir -p `brew --prefix`/share/zsh/site-functions
    ln -s `brew --prefix`/Library/Contributions/brew_zsh_completion.zsh \
      `brew --prefix`/share/zsh/site-functions/_brew
  fi
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
# Vanilla shell
zplug "yous/vanilli.sh"
# Additional completion definitions for Zsh
zplug "zsh-users/zsh-completions"
# Load the theme.
zplug "yous/lime"
# Syntax highlighting bundle. zsh-syntax-highlighting must be loaded after
# excuting compinit command and sourcing other plugins.
zplug "zsh-users/zsh-syntax-highlighting", nice:9
# ZSH port of Fish shell's history search feature
zplug "zsh-users/zsh-history-substring-search", nice:10

# Install plugins if there are plugins that have not been installed
if ! zplug check; then
  zplug install
fi
# Then, source plugins and add commands to $PATH
zplug load

# zsh-users/zsh-completions
zmodload zsh/terminfo
[ -n "${terminfo[kcuu1]}" ] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[ -n "${terminfo[kcud1]}" ] && bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Set PATH to include user's bin if it exists
if [ -d "$HOME/bin" ]; then
  add_to_path_once "$HOME/bin"
fi

# Load autojump
if command -v autojump &> /dev/null; then
  if [ -f /etc/profile.d/autojump.zsh ]; then
    source /etc/profile.d/autojump.zsh
  elif [ -f /usr/share/autojump/autojump.zsh ]; then
    source /usr/share/autojump/autojump.zsh
  elif command -v brew &> /dev/null && [ -f `brew --prefix`/etc/autojump.sh ]; then
    source `brew --prefix`/etc/autojump.sh
  fi
elif [ -f "$HOME/.autojump/etc/profile.d/autojump.sh" ]; then
  source "$HOME/.autojump/etc/profile.d/autojump.sh"
fi

# Load fzf
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh

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
  eval "$(rbenv init - zsh)"
fi

# Load pyenv
if command -v pyenv &> /dev/null; then
  eval "$(pyenv init - zsh)"
  if command -v pyenv-virtualenv-init &> /dev/null; then
    eval "$(pyenv virtualenv-init - zsh)"
  fi
elif [ -e "$HOME/.pyenv" ]; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init - zsh)"
  eval "$(pyenv virtualenv-init - zsh)"
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
if command -v go &> /dev/null; then
  [ -d "$HOME/.go" ] || mkdir "$HOME/.go"
  export GOPATH="$HOME/.go"
  export PATH="$PATH:$GOPATH/bin"
fi

# Oh My Zsh sets custom LSCOLORS from lib/theme-and-appearance.zsh
# This is default LSCOLORS from the man page of ls
[[ "$(uname)" == 'Darwin' ]] && export LSCOLORS=exfxcxdxbxegedabagacad

# Check if reboot is required for Ubuntu
if [ -f /usr/lib/update-notifier/update-motd-reboot-required ]; then
  function reboot-required() {
    /usr/lib/update-notifier/update-motd-reboot-required
  }
fi

# Enable keychain
if command -v keychain &> /dev/null; then
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

# Source local zshrc
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
