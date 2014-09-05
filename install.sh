#!/bin/bash
DIR="$( cd $( dirname "$0" ) && pwd )"

function echoerr()
{
  echo "$@" 1>&2
}

function init_submodules()
{
  git submodule init
  git submodule update
}

function git_clone()
{
  if [ ! -e "$HOME/$2" ]; then
    echo "Cloning '$1'..."
    git clone "$1" "$HOME/$2"
  else
    echoerr "~/$2 already exists."
  fi
}

function replace_file()
{
  DEST=${2:-.$1}

  # http://www.tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
  # File exists and is a directory.
  [ ! -d $(dirname "$HOME/$DEST") ] && mkdir -p $(dirname "$HOME/$DEST")

  # FILE exists and is a symbolic link.
  if [ -h "$HOME/$DEST" ]; then
    if rm "$HOME/$DEST" && ln -s "$DIR/$1" "$HOME/$DEST"; then
      echo "Updated ~/$DEST"
    else
      echoerr "Failed to update ~/$DEST"
    fi
  # FILE exists.
  elif [ -e "$HOME/$DEST" ]; then
    if mv "$HOME/$DEST" "$HOME/$DEST.old"; then
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
    git_clone 'https://github.com/gmarik/Vundle.vim.git' ".vim/bundle/Vundle.vim"
    for FILENAME in \
      'antigen' \
      'gitconfig' \
      'gitignore_global' \
      'irbrc' \
      'screenrc' \
      'tmux.conf' \
      'vimrc' \
      'zshrc'
    do
      replace_file $FILENAME
    done
    for FILENAME in bin/*
    do
      replace_file $FILENAME $FILENAME
    done
    echo 'Done.'
    ;;
  brew)
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    ;;
  rbenv)
    replace_file 'rbenv'
    echo 'Done.'
    ;;
  rvm)
    \curl -sSL https://get.rvm.io | bash -s stable
    ;;
  *)
    echo "usage: $(basename $0) <command>"
    echo ''
    echo 'Available commands:'
    echo '    link    Install symbolic links'
    echo '    brew    Install Homebrew'
    echo '    rbenv   Install rbenv'
    echo '    rvm     Install RVM'
    ;;
esac
