#!/usr/bin/env bash

mkdir -p $HOME/.vim/files/backup
mkdir -p $HOME/.vim/files/swap
mkdir -p $HOME/.vim/files/undo
mkdir -p $HOME/.vim/files/info

declare -A osInfo;
osInfo[/etc/debian_version]="apt-get install -y"
osInfo[/etc/alpine-release]="apk --update add"
osInfo[/etc/centos-release]="yum install -y"
osInfo[/etc/fedora-release]="dnf install -y"

for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        package_manager=${osInfo[$f]}
    fi
done

echo "Package manager ${package_manager}"

packagelist=()
packagelist+=( "vim" )
packagelist+=( "git" )
packagelist+=( "build-essential" )
packagelist+=( "clang" )
packagelist+=( "gcc" )
packagelist+=( "cmake" )
packagelist+=( "wget" )
packagelist+=( "curl" )
packagelist+=( "autoconf" )
packagelist+=( "ninja-build" )
packagelist+=( "python" )
packagelist+=( "python-dev" )
packagelist+=( "terminator" )
packagelist+=( "tilix" )
packagelist+=( "shellcheck" )
packagelist+=( "ripgrep" )
packagelist+=( "byobu" )
packagelist+=( "meld" )

packages=$( IFS=$' '; echo "${packagelist[*]}" )

echo ${packages}

set -x
sudo ${package_manager} ${packages}
set +x

#--------------------------------------------------------------------
if [[ -d "$HOME/liquidprompt" ]];then
    echo "$HOME/liquidprompt/ already exists"
    git -C $HOME/liquidprompt pull 
else
    git clone https://github.com/nojhan/liquidprompt.git /$HOME/liquidprompt
fi

#--------------------------------------------------------------------
#install rust
#curl https://sh.rustup.rs -sSf | sh

#--------------------------------------------------------------------
# Duzzy file searcher
if [[ -d "$HOME/.fzf" ]]; then 
    git -C $HOME/.fzf pull
    yes | . $HOME/.fzf/install
else
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

#--------------------------------------------------------------------
#Liquidprompt
if [[ -f ~/.config/liquidpromptrc ]]; then
    echo "Liquidpromptrc exists!"
else
    ln -s `readlink -f liquidpromptrc` $HOME/.config/
fi

#--------------------------------------------------------------------
#$USER bash preferences
grep -n --color "bashUserPost" $HOME/.bashrc
if [[ $? -ne 0 ]]; then
    echo "Installing .bashUserpost"
    ln -s `readlink -f .bashUserPost` $HOME/.bashUserPost
    echo "source ~/.bashUserPost" >> $HOME/.bashrc
else
    echo "bashUserPort is already sourced in bashrc"
fi

echo "Reloading bashrc"
source ~/.bashrc


#--------------------------------------------------------------------
#Vim config
if [[ -f $HOME/.vimrc ]];then
	echo ".vimrc exists in $HOME"
else
	echo "Creating symlink for .vimrc"
	ln -s `readlink -f .vimrc` $HOME/.vimrc
fi

#--------------------------------------------------------------------
#Xresources
if [[ -f $HOME/.Xresources ]];then
    echo "$HOME/.Xresources found"
else
    echo "Creating symlink for .Xresources"
    ln -s `readlink -f .Xresources` $HOME/.Xresources
fi


#--------------------------------------------------------------------
#Git Config
rm -f $HOME/.gitconfig
cp -fv .gitconfig $HOME/.gitconfig
read -p 'git user.name ' gitconfigusername
read -p 'git user.email ' gitconfiguseremail

set -x
git config --global user.name "${gitconfigusername}"
git config --global user.email "${gitconfiguseremail}"
set +x
