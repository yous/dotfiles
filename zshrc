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
    local cores_num
    if [[ "$(uname)" == 'Darwin' ]]; then
      cores_num="$(sysctl -n hw.ncpu)"
    else
      cores_num="$(nproc)"
    fi
    bundle install --jobs=$cores_num $@
  else
    bundle install $@
  fi
}

if command -v brew >/dev/null; then
  BREW_PREFIX="$(brew --prefix)"
fi

# Use Antibody
if [[ "$(uname)" == 'Linux' ]] || [[ "$(uname)" == 'Darwin' ]]; then
  # Check if Antibody is installed
  if [[ "$(uname)" == 'Linux' ]] && ! command -v antibody >/dev/null; then
    curl -s https://raw.githubusercontent.com/getantibody/installer/master/install | bash -s
  fi

  # Load Antibody
  source <(antibody init)

  antibody bundle <<EOF
  # Additional completion definitions for Zsh
  zsh-users/zsh-completions

  # Simple standalone Zsh theme
  yous/lime

  # A lightweight start point of shell configuration. This includes compinit.
  yous/vanilli.sh

  # Syntax-highlighting for Zshell – fine granularity, number of features, 40
  # work hours themes (short name F-Sy-H)
  zdharma/fast-syntax-highlighting

  # ZSH port of Fish shell's history search feature. zsh-syntax-highlighting
  # must be loaded before this.
  zsh-users/zsh-history-substring-search
EOF

  # zsh-users/zsh-history-substring-search
  zmodload zsh/terminfo
  [ -n "${terminfo[kcuu1]}" ] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
  [ -n "${terminfo[kcud1]}" ] && bindkey "${terminfo[kcud1]}" history-substring-search-down
  bindkey -M emacs '^P' history-substring-search-up
  bindkey -M emacs '^N' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
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
  elif [ -f /etc/profile.d/autojump.zsh ]; then
    source /etc/profile.d/autojump.zsh
  elif [ -f /usr/share/autojump/autojump.zsh ]; then
    source /usr/share/autojump/autojump.zsh
  elif [ -n "$BREW_PREFIX" ]; then
    if [ -f "$BREW_PREFIX/etc/autojump.sh" ]; then
      source "$BREW_PREFIX/etc/autojump.sh"
    fi
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
fi

# Load rbenv
if [ -e "$HOME/.rbenv" ]; then
  add_to_path_once "$HOME/.rbenv/bin"
  eval "$(rbenv init - zsh)"
fi

# Load pyenv
if command -v pyenv >/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  eval "$(pyenv init - zsh)"
  if command -v pyenv-virtualenv-init >/dev/null; then
    eval "$(pyenv virtualenv-init - zsh)"
  fi
elif [ -e "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  add_to_path_once "$HOME/.pyenv/bin"
  eval "$(pyenv init - zsh)"
  eval "$(pyenv virtualenv-init - zsh)"
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
      pushd -q ..
      popd -q
    fi
  fi
fi

# Check if reboot is required for Ubuntu
if [ -f /usr/lib/update-notifier/update-motd-reboot-required ]; then
  function reboot-required() {
    /usr/lib/update-notifier/update-motd-reboot-required
  }
fi

# Enable keychain
if command -v keychain >/dev/null; then
  if [ -f "$HOME/.ssh/id_rsa" ]; then
    eval `keychain --eval --quiet --agents ssh id_rsa`
  elif [ -f "$HOME/.ssh/id_ed25519" ]; then
    eval `keychain --eval --quiet --agents ssh id_ed25519`
  fi
fi

# Unset local functions and variables
unset BREW_PREFIX
unset -f add_to_path_once

# Define aliases
# Enable color support
if ls --color -d . >/dev/null 2>&1; then
  alias ls='ls --color=auto'
else
  alias ls='ls -G'
fi
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
alias gap='git add --patch'
alias gb='git branch'
alias gba='git branch --all'
alias gbl='git blame'
alias gbv='git branch -vv'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcb='git checkout -b'
alias gcd='git checkout develop'
alias gcl='git clone --recurse-submodules'
alias gcm='git checkout master'
alias gco='git checkout'
alias gcop='git checkout --patch'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gdc='git diff --cached'
alias gf='git fetch'
alias gfl='git-flow'
alias ggp='git push origin HEAD'
alias gl='git pull'
alias glg='git log --decorate --graph --pretty=format:"%C(auto,yellow)%h %C(auto,blue)%ar %C(auto,green)%an%C(auto,reset) %s%C(auto)%d"'
alias glga='glg --all'
alias glr='git pull --rebase'
alias gma='git merge --abort'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grs='git reset'
alias grsp='git reset --patch'
alias grup='git remote update'
alias grv='git remote -v'
alias gsh='git show'
alias gst='git status'
alias gsta='git -c commit.gpgsign=false stash'
alias gstd='git stash drop'
alias gstp='git stash pop'
alias gsu='git submodule update'
alias gsur='git submodule update --remote'

# Vim
if command -v vim >/dev/null; then
  alias v='vim'
  alias vi='vim'
elif command -v vi >/dev/null; then
  alias v='vi'
fi
if command -v nvim >/dev/null; then
  alias nv='nvim'
fi

# http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized
function man() {
  env \
    LESS_TERMCAP_mb=$'\e[1;31m' \
    LESS_TERMCAP_md=$'\e[1;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[1;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[1;32m' \
    man "$@"
}

# Source local zshrc
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
