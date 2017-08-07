#!/bin/bash

cd ~/
backuploc="~/backupconfig"
mkdir -p $backuploc
echo "Moving Existing Config Files to backup location [ $backuploc ] "
mv ~/.bash* $backuploc
mv ~/.vim* $backuploc

cwd=$(pwd)
PATH_TO_DOTFILES=~/dotfiles
symlinkoption=s #softlink it.
BASHFILES=$PATH_TO_DOTFILES/.bash*
VIMFILES=$PATH_TO_DOTFILES/.vim*



echo "cwd [$cwd]"

for FILE in $BASHFILES
do
  echo "Soft-linking $FILE in $cwd"
  # take action on each file. $f store current file name
  ln -$symlinkoption $FILE 
done

for FILE in $VIMFILES
do
  echo "Soft-linking $FILE in $cwd"
  # take action on each file. $f store current file name
  ln -$symlinkoption $FILE 
done

ln -$symlinkoption ~/dotfiles/.fonts/
cd ~/.config

ln -s ~/dotfiles/terminator
ln -s ~/dotfiles/liquidpromptrc
ln -s ~/dotfiles/.fonts/

echo "Cloning Liquidprompt"
git clone https://github.com/nojhan/liquidprompt.git ~/
echo "Cloning Vundle"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo "Installing vim plugins"
vim +PluginInstall +qall
