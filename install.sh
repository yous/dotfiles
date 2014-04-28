#!/bin/bash
DIR="$( cd $( dirname "$0" ) && pwd )"

function replace_file()
{
  if [ -h "$HOME/.$1" ]; then
    rm "$HOME/.$1"
    ln -s "$DIR/$1" "$HOME/.$1"
    echo "Updated ~/.$1"
  elif [ -e "$HOME/.$1" ]; then
    mv "$HOME/.$1" "$HOME/.$1.old"
    echo "Renamed ~/.$1 to ~/.$1.old"
    ln -s "$DIR/$1" "$HOME/.$1"
    echo "Created ~/.$1"
  fi
}

for FILENAME in "gitignore" "irbrc" "oh-my-zsh" "screenrc" "tmux.conf" "vimrc" "zshrc"
do
  replace_file $FILENAME
done
echo "Done."
