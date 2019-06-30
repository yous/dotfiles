#!/usr/bin/env bash
set -e

DIRNAME="$(dirname "$0")"
DIR="$(cd "$DIRNAME" && pwd)"

echoerr() {
  echo "$@" 1>&2
}

init_submodules() {
  (cd "$DIR" && git submodule init)
  (cd "$DIR" && git submodule update)
}

git_clone() {
  if [ ! -e "$HOME/$2" ]; then
    echo "Cloning '$1'..."
    git clone "$1" "$HOME/$2"
  else
    # shellcheck disable=SC2088
    echoerr "~/$2 already exists."
  fi
}

rename_with_backup() {
  if [ ! -e "$2" ]; then
    if mv "$1" "$2"; then
      return 0
    fi
  else
    local num
    num=1
    while [ -e "$2.~$num~" ]; do
      (( num++ ))
    done

    if mv "$2" "$2.~$num~" && mv "$1" "$2"; then
      return 0
    fi
  fi
  return 1
}

replace_file() {
  DEST=${2:-.$1}

  if [ -e "$DIR/$1" ]; then
    SRC="$DIR/$1"
  else
    SRC="$HOME/$1"
  fi

  # http://www.tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
  # File exists and is a directory.
  [ ! -d "$(dirname "$HOME/$DEST")" ] && mkdir -p "$(dirname "$HOME/$DEST")"

  # FILE exists and is a symbolic link.
  if [ -h "$HOME/$DEST" ]; then
    if rm "$HOME/$DEST" && ln -s "$SRC" "$HOME/$DEST"; then
      echo "Updated ~/$DEST"
    else
      echoerr "Failed to update ~/$DEST"
    fi
  # FILE exists.
  elif [ -e "$HOME/$DEST" ]; then
    if rename_with_backup "$HOME/$DEST" "$HOME/$DEST.old"; then
      echo "Renamed ~/$DEST to ~/$DEST.old"
      if ln -s "$SRC" "$HOME/$DEST"; then
        echo "Created ~/$DEST"
      else
        echoerr "Failed to create ~/$DEST"
      fi
    else
      echoerr "Failed to rename ~/$DEST to ~/$DEST.old"
    fi
  else
    if ln -s "$SRC" "$HOME/$DEST"; then
      echo "Created ~/$DEST"
    else
      echoerr "Failed to create ~/$DEST"
    fi
  fi
}

install_link() {
  init_submodules
  for FILENAME in \
    'aliases' \
    'bashrc' \
    'ctags' \
    'gemrc' \
    'git-templates' \
    'gitattributes_global' \
    'gitconfig' \
    'gitignore_global' \
    'ideavimrc' \
    'inputrc' \
    'irbrc' \
    'minttyrc' \
    'npmrc' \
    'profile' \
    'screenrc' \
    'tern-config' \
    'tmux.conf' \
    'vintrc.yaml' \
    'vimrc' \
    'zprofile' \
    'zshrc'
  do
    replace_file "$FILENAME"
  done
  replace_file 'pip.conf' '.pip/pip.conf'
  replace_file 'tpm' '.tmux/plugins/tpm'
  [ ! -d "$HOME/.vim" ] && mkdir "$HOME/.vim"
  replace_file '.vim' '.config/nvim'
  replace_file 'vimrc' '.config/nvim/init.vim'
  for FILENAME in \
    'diff-highlight' \
    'diff-hunk-list' \
    'pyg' \
    'server'
  do
    replace_file "bin/$FILENAME" "bin/$FILENAME"
  done
  echo 'Done.'
}

install_formulae() {
  local brew_list installed
  brew_list=()
  while IFS='' read -r line; do
    brew_list+=("$line")
  done < <(brew list --full-name)
  while read -r cmd; do
    trap 'break' INT
    [[ -z "$cmd" || ${cmd:0:1} == '#' ]] && continue
    IFS=' ' read -ra brew_args <<< "$cmd"
    if [ "${brew_args[0]}" = 'install' ]; then
      installed=0
      for e in "${brew_list[@]}"; do
        if [ "$e" = "${brew_args[1]}" ]; then
          installed=1
          break
        fi
      done
      if [ "$installed" -eq 1 ]; then
        echo "${brew_args[1]} is already installed"
        continue
      fi
    fi
    brew "${brew_args[@]}"
  done < "$DIR/Brewfile" && echo 'Done.'
}

case "$1" in
  link)
    install_link
    ;;
  brew)
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ;;
  chruby)
    if [ "$(uname)" = 'Darwin' ]; then
      brew install chruby
    else
      wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
      tar -xzvf chruby-0.3.9.tar.gz
      cd chruby-0.3.9/
      sudo make install
    fi
    ;;
  formulae)
    install_formulae
    ;;
  linuxbrew)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    ;;
  pwndbg)
    init_submodules
    cd "${DIR}/pwndbg"
    ./setup.sh
    ;;
  pyenv)
    if [ "$(uname)" = 'Darwin' ]; then
      brew install pyenv
      brew install pyenv-virtualenv
    else
      curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
    fi
    ;;
  rbenv)
    if [ "$(uname)" = 'Darwin' ]; then
      brew install rbenv
    else
      git_clone https://github.com/rbenv/rbenv.git .rbenv
      git_clone https://github.com/rbenv/ruby-build.git .rbenv/plugins/ruby-build
    fi
    echo 'Done.'
    ;;
  ruby-install)
    if [ "$(uname)" = 'Darwin' ]; then
      brew install ruby-install
    else
      wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
      tar -xzvf ruby-install-0.7.0.tar.gz
      cd ruby-install-0.7.0/
      sudo make install
    fi
    ;;
  rvm)
    command curl -sSL https://get.rvm.io | bash -s stable
    ;;
  weechat)
    replace_file 'weechat'
    ;;
  z)
    init_submodules
    replace_file 'z/z.sh' '.z.sh'
    ;;
  *)
    echo "usage: $(basename "$0") <command>"
    echo ''
    echo 'Available commands:'
    echo '    link         Install symbolic links'
    echo '    brew         Install Homebrew'
    echo '    chruby       Install chruby'
    echo '    formulae     Install Homebrew formulae using Brewfile'
    echo '    linuxbrew    Install Homebrew on Linux'
    echo '    pwndbg       Install pwndbg'
    echo '    pyenv        Install pyenv with pyenv-virtualenv'
    echo '    rbenv        Install rbenv'
    echo '    ruby-install Install ruby-install'
    echo '    rvm          Install RVM'
    echo '    weechat      Install WeeChat configuration'
    echo '    z            Install z'
    ;;
esac
