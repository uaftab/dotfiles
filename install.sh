#!/bin/bash

#Author: Lemniscate Snickets  

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

sudo apt-get install -y linux-headers-$(uname -r)

sudo apt-get install -y \
	vim terminator \
	build-essential clang llvm autoconf \
	cmake git ninja-build \
	wget curl \
	python python-dev \
	

#install rust
curl -sSf https://static.rust-lang.org/rustup.sh | sh


#install vundle 
#git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#cp .vim* ~/
#vim +PluginInstall +qall

#cp -R terminator/ ~/config/
#cp .xscreensaver ~/
sudo apt-get install -y xfce4-*
sudo apt-get install -y xfce-keyboard-shortcuts
sudo apt-get install -y cabextract font-manager
sudo apt-get install -y gtk2-engines-murrine
cd ~
mkdir -p ~/.themes
cd .themes 
wget https://github.com/shimmerproject/Greybird/archive/master.zip
unzip master.zip
rm master.zip
cd ~
mkdir -p ~/.icons
cd .icons 
wget https://github.com/shimmerproject/elementary-xfce/archive/master.zip
unzip master.zip
mv elementary*/* .
rm master.zip

#sudo ./battery_install.sh
