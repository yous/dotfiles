if [[ "$OSTYPE" == "darwin"* ]]; then
  export LC_ALL=ko_KR.UTF-8
  export LANG=ko_KR.UTF-8
elif locale -a | grep -q "en_US\.UTF-8\|en_US\.utf8"; then
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
