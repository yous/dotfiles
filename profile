if [[ "$(uname)" == 'Darwin' ]]; then
  export LANG=en_US.UTF-8
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
