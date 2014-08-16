#!/bin/bash
DIR="$( cd $( dirname "$0" ) && pwd )"

function echoerr()
{
  echo "$@" 1>&2
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

if [ $# -eq 0 ]; then
  for FILENAME in \
    "antigen" \
    "gitignore" \
    "irbrc" \
    "screenrc" \
    "tmux.conf" \
    "vimrc" \
    "zshrc"
  do
    replace_file $FILENAME
  done
  echo "Done."
elif [ $# -eq 1 ] && [ $1 == "--rbenv" ]; then
  replace_file "rbenv"
  echo "Done."
else
  echo "Usage: $(basename $0) [--rbenv]"
fi
