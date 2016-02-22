#!/bin/bash
DIRNAME="$(dirname "$0")"
DIR="$(cd "$DIRNAME" && pwd)"

function echoerr() {
  echo "$@" 1>&2
}

function init_submodules() {
  git submodule init
  git submodule update
}

function git_clone() {
  if [ ! -e "$HOME/$2" ]; then
    echo "Cloning '$1'..."
    git clone "$1" "$HOME/$2"
  else
    echoerr "~/$2 already exists."
  fi
}

function replace_file() {
  DEST=${2:-.$1}

  # http://www.tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
  # File exists and is a directory.
  [ ! -d "$(dirname "$HOME/$DEST")" ] && mkdir -p "$(dirname "$HOME/$DEST")"

  # FILE exists and is a symbolic link.
  if [ -h "$HOME/$DEST" ]; then
    if rm "$HOME/$DEST" && ln -s "$DIR/$1" "$HOME/$DEST"; then
      echo "Updated ~/$DEST"
    else
      echoerr "Failed to update ~/$DEST"
    fi
  # FILE exists.
  elif [ -e "$HOME/$DEST" ]; then
    if mv --backup=number "$HOME/$DEST" "$HOME/$DEST.old"; then
      echo "Renamed ~/$DEST to ~/$DEST.old"
      if ln -s "$DIR/$1" "$HOME/$DEST"; then
        echo "Created ~/$DEST"
      else
        echoerr "Failed to create ~/$DEST"
      fi
    else
      echoerr "Failed to rename ~/$DEST to ~/$DEST.old"
    fi
  else
    if ln -s "$DIR/$1" "$HOME/$DEST"; then
      echo "Created ~/$DEST"
    else
      echoerr "Failed to create ~/$DEST"
    fi
  fi
}

case "$1" in
  link)
    init_submodules
    for FILENAME in \
      'bashrc' \
      'gemrc' \
      'gitattributes_global' \
      'gitconfig' \
      'gitignore_global' \
      'ideavimrc' \
      'inputrc' \
      'irbrc' \
      'profile' \
      'screenrc' \
      'tmux.conf' \
      'vim/bundle/netrw' \
      'vimrc' \
      'weechat' \
      'zprofile' \
      'zshrc'
    do
      replace_file "$FILENAME"
    done
    replace_file 'tpm' '.tmux/plugins/tpm'
    echo 'Done.'
    ;;
  brew)
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ;;
  formulae)
    while read COMMAND; do
      trap 'break' INT
      [[ -z "$COMMAND" || ${COMMAND:0:1} == '#' ]] && continue
      brew $COMMAND
    done < "$DIR/Brewfile" && echo 'Done.'
    ;;
  npm)
    if ! which npm &> /dev/null; then
      echoerr 'command not found: npm'
    else
      for PACKAGE in \
        'csslint' \
        'jshint' \
        'jslint' \
        'jsonlint'
      do
        if which $PACKAGE &> /dev/null; then
          echoerr "$PACKAGE is already installed."
        else
          echo "npm install -g $PACKAGE"
          npm install -g "$PACKAGE"
        fi
      done
    fi
    ;;
  pyenv)
    curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
    ;;
  rbenv)
    git_clone https://github.com/sstephenson/rbenv.git .rbenv
    git_clone https://github.com/sstephenson/ruby-build.git .rbenv/plugins/ruby-build
    echo 'Done.'
    ;;
  rvm)
    \curl -sSL https://get.rvm.io | bash -s stable
    ;;
  zplug)
    git_clone https://github.com/b4b4r07/zplug.git .zplug/repos/b4b4r07/zplug
    ln -s "$HOME/.zplug/repos/b4b4r07/zplug/zplug" "$HOME/.zplug/zplug"
    echo 'Done.'
    ;;
  *)
    echo "usage: $(basename "$0") <command>"
    echo ''
    echo 'Available commands:'
    echo '    link      Install symbolic links'
    echo '    brew      Install Homebrew'
    echo '    formulae  Install Homebrew formulae using Brewfile'
    echo '    npm       Install global Node.js packages'
    echo '    pyenv     Install pyenv with pyenv-virtualenv'
    echo '    rbenv     Install rbenv'
    echo '    rvm       Install RVM'
    echo '    zplug     Install zplug'
    ;;
esac
