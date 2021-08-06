UNAME="$(uname)"
if [ "$UNAME" = 'Darwin' ]; then
  export LANG=en_US.UTF-8
fi

if [ -n "$ZSH_VERSION" ]; then
  # Oh My Zsh sets custom LSCOLORS from lib/theme-and-appearance.zsh
  # This is default LSCOLORS from the man page of ls
  [ "$UNAME" = 'Darwin' ] && export LSCOLORS=exfxcxdxbxegedabagacad
fi

add_to_path_once() {
  case ":$PATH:" in
    *":$1:"*)
      ;;
    *)
      export PATH="$1:$PATH"
      ;;
  esac
}

# Add /usr/local/bin to PATH for Mac OS X
if [ "$UNAME" = 'Darwin' ]; then
  add_to_path_once "/usr/local/bin:/usr/local/sbin"
fi

# Load Linuxbrew
if [ -d "$HOME/.linuxbrew" ]; then
  eval $("$HOME/.linuxbrew/bin/brew" shellenv)
elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
  eval $("/home/linuxbrew/.linuxbrew/bin/brew" shellenv)
fi

# Set PATH to include user's bin if it exists
if [ -d "$HOME/bin" ]; then
  add_to_path_once "$HOME/bin"
fi
if [ -d "$HOME/.local/bin" ]; then
  add_to_path_once "$HOME/.local/bin"
fi

# Load n
if command -v n >/dev/null; then
  export N_PREFIX="$HOME/.n"
  add_to_path_once "$N_PREFIX/bin"
fi

# Set GOPATH for Go
if command -v go >/dev/null; then
  [ ! -e "$HOME/.go" ] && mkdir "$HOME/.go"
  export GOPATH="$HOME/.go"
  case ":$PATH:" in
    *":$GOPATH/bin:"*)
      ;;
    *)
      export PATH="$PATH:$GOPATH/bin"
      ;;
  esac
fi

# Set PATH for Rust
if [ -d "$HOME/.cargo" ]; then
  add_to_path_once "$HOME/.cargo/bin"
fi

# Load rbenv
if [ -e "$HOME/.rbenv" ]; then
  add_to_path_once "$HOME/.rbenv/bin"
fi

# Load pyenv
if command -v pyenv >/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  eval "$(pyenv init --path 2>/dev/null)"
elif [ -e "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  add_to_path_once "$HOME/.pyenv/bin"
  eval "$(pyenv init --path 2>/dev/null)"
fi

# Unset local functions and variables
unset -f add_to_path_once
unset UNAME

# WSL
if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  export COLORTERM='truecolor'
fi

# Set VISUAL
if command -v vim >/dev/null; then
  export VISUAL="$(command -v vim)"
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
