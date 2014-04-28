#!/bin/bash
DIR="$( cd $( dirname "$0" ) && pwd )"

function echoerr()
{
  echo "$@" 1>&2
}

function replace_file()
{
  if [ -h "$HOME/.$1" ]; then
    if rm "$HOME/.$1" && ln -s "$DIR/$1" "$HOME/.$1"; then
      echo "Updated ~/.$1"
    else
      echoerr "Failed to update ~/.$1"
    fi
  elif [ -e "$HOME/.$1" ]; then
    if mv "$HOME/.$1" "$HOME/.$1.old"; then
      echo "Renamed ~/.$1 to ~/.$1.old"
      if ln -s "$DIR/$1" "$HOME/.$1"; then
        echo "Created ~/.$1"
      else
        echoerr "Failed to create ~/.$1"
      fi
    else
      echoerr "Failed to rename ~/.$1 to ~/.$1.old"
    fi
  fi
}

for FILENAME in "gitignore" "irbrc" "oh-my-zsh" "screenrc" "tmux.conf" "vimrc" "zshrc"
do
  replace_file $FILENAME
done
echo "Done."
