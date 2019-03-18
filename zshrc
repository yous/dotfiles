# Make the $path array have unique values.
typeset -U path

add_to_path_once() {
  path=("$1" $path)
}

bundle_install() {
  local cores_num
  if [ "$(uname)" = 'Darwin' ]; then
    cores_num="$(sysctl -n hw.ncpu)"
  else
    cores_num="$(nproc)"
  fi
  bundle install --jobs="$cores_num" "$@"
}

if command -v brew >/dev/null; then
  BREW_PREFIX="$(brew --prefix)"
fi

# Use Zplugin
if [ ! -e "$HOME/.zplugin/bin/zplugin.zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"
fi
source "$HOME/.zplugin/bin/zplugin.zsh"

# Additional completion definitions for Zsh
if is-at-least 5.3; then
  zplugin ice lucid wait'0' blockf
else
  zplugin ice blockf
fi
zplugin light zsh-users/zsh-completions
# Simple standalone Zsh theme
zplugin light yous/lime
# A lightweight start point of shell configuration
zplugin light yous/vanilli.sh
# Syntax-highlighting for Zshell – fine granularity, number of features, 40 work
# hours themes (short name F-Sy-H)
is-at-least 5.3 && zplugin ice lucid wait'0' atinit'zpcompinit; zpcdreplay'
zplugin light zdharma/fast-syntax-highlighting
# ZSH port of Fish shell's history search feature. zsh-syntax-highlighting must
# be loaded before this.
zplugin light zsh-users/zsh-history-substring-search

if ! is-at-least 5.3; then
  autoload -Uz compinit
  compinit
  zplugin cdreplay -q
fi

# zsh-users/zsh-history-substring-search
zmodload zsh/terminfo
[ -n "${terminfo[kcuu1]}" ] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[ -n "${terminfo[kcud1]}" ] && bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

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
  reboot-required() {
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
if [ -f "$HOME/.aliases" ]; then
  source "$HOME/.aliases"
fi

# Source local zshrc
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
