#!/bin/bash
DIR="$( cd $( dirname "$0" ) && pwd )"

function replace_file() {
	if [ -h "$HOME/.$1" ]; then
		rm "$HOME/.$1"
	elif [ -e "$HOME/.$1" ]; then
		mv "$HOME/.$1" "$HOME/.$1.old"
	fi
	ln -s "$DIR/$1" "$HOME/.$1"
}

for FILENAME in "irbrc" "screenrc" "tmux.conf" "vim/ftplugin" "vimrc" "zshrc"
do
	replace_file $FILENAME
done
