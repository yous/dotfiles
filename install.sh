#!/bin/bash
DIR="$( cd $( dirname "$0" ) && pwd )"
mv ~/.screenrc ~/.screenrc.old
ln -s $DIR/screenrc ~/.screenrc
mv ~/.vim/ftplugin ~/.vim/ftplugin.old
ln -s $DIR/vimfiles/ftplugin ~/.vim/ftplugin
mv ~/.vimrc ~/.vimrc.old
ln -s $DIR/vimrc ~/.vimrc
mv ~/.zshrc ~/.zshrc.old
ln -s $DIR/zshrc ~/.zshrc
