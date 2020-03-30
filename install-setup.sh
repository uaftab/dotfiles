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

packages=$( IFS=$' '; echo "${packagelist[*]}" )

echo ${packages}

set -x
sudo ${package_manager} ${packages}
set +x

if [[ -d "$HOME/liquidprompt" ]];then
    echo "$HOME/liquidprompt/ already exists"
    git -C $HOME/liquidprompt pull 
else
    git clone https://github.com/nojhan/liquidprompt.git /$HOME/liquidprompt
fi
#install rust
#curl https://sh.rustup.rs -sSf | sh

if [[ -d "$HOME/.fzf" ]]; then 
    git -C $HOME/.fzf pull
    yes | . $HOME/.fzf/install
else
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

if [[ -f ~/.config/liquidpromptrc ]]; then
    echo "Liquidpromptrc exists!"
else
    ln -s `readlink -f liquidpromptrc` $HOME/.config/
fi
