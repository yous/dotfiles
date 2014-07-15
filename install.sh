#!/bin/bash
DIR="$( cd $( dirname "$0" ) && pwd )"

function echoerr()
{
  echo "$@" 1>&2
}

function replace_file()
{
  # http://www.tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
  # FILE exists and is a symbolic link.
  if [ -h "$HOME/.$1" ]; then
    if rm "$HOME/.$1" && ln -s "$DIR/$1" "$HOME/.$1"; then
      echo "Updated ~/.$1"
    else
      echoerr "Failed to update ~/.$1"
    fi
  # FILE exists.
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
  else
    if ln -s "$DIR/$1" "$HOME/.$1"; then
      echo "Created ~/.$1"
    else
      echoerr "Failed to create ~/.$1"
    fi
  fi
}

for FILENAME in \
  "antigen" \
  "gitignore" \
  "irbrc" \
  "screenrc" \
  "tmux.conf" \
  "vimrc" \
  "zsh" \
  "zshrc"
do
  replace_file $FILENAME
done
echo "Done."
