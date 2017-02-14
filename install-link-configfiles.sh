#!/bin/bash

cd ~/

echo "Removing Files"
rm -rf ~/.bash*
rm -rf ~/.vim*

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
