#!/bin/bash
DIR="$( cd $( dirname "$0" ) && pwd )"

if [ -e "~/.screenrc" ]; then
	mv ~/.screenrc ~/.screenrc.old
fi
ln -s $DIR/screenrc ~/.screenrc

if [ -e "~/.tmux.conf" ]; then
	mv ~/.tmux.conf ~/.tmux.conf.old
fi
ln -s $DIR/tmux.conf ~/.tmux.conf

if [ -e "~/.vim/ftplugin" ]; then
	mv ~/.vim/ftplugin ~/.vim/ftplugin.old
fi
ln -s $DIR/vimfiles/ftplugin ~/.vim/ftplugin

if [ -e "~/.vimrc" ]; then
	mv ~/.vimrc ~/.vimrc.old
fi
ln -s $DIR/vimrc ~/.vimrc

if [ -e "~/.zshrc" ]; then
	mv ~/.zshrc ~/.zshrc.old
fi
ln -s $DIR/zshrc ~/.zshrc
