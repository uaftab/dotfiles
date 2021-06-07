#!/usr/bin/env bash

# set -eE -o functrace

# failure() {
#   local lineno=$1
#   local msg=$2
#   echo "Failed at line $lineno: $msg"
# }
# trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

LOGFILE="/tmp"
SCRIPTPATH="$(readlink -f ${0} | rev | cut -f2- -d"/" | rev)"

#--------------------------------------------------------------------
function pass()
{
    echo -e "\u001b[32;1m[  OK  ]\u001b[0m $1"
}

function fail()
{
    echo -e "\u001b[31;1m[ FAIL ]\u001b[0m $1"
}

function info()
{
    echo -e "\u001b[33;1m[ INFO ]\u001b[0m $1"
}

#--------------------------------------------------------------------
# Indent the input line
function indent() 
{
    sed 's/^/         /';
}
#--------------------------------------------------------------------
# Function to create directories
# $1=create path
function createdir()
{
    tocreate="${1}"
    if [[ -d "${tocreate}" ]];
    then
        pass "${tocreate} already exists"
    else
        mkdir -p "${tocreate}"
        wasItCreated=$?
        if [[ ${wasItCreated} -eq 0 ]];
        then
            pass "Created directory ${tocreate}"
        else
            fail "Could not create ${tocreate} - ${wasItCreated}"
            exit ${wasItCreated}
        fi
    fi
}

#--------------------------------------------------------------------
# Function to link a file 
# $1=source
# $2=destination
function linkfile()
{
    frompath="${1}"
    linkto="${2}"
    if [[ -f "${linkto}" ]];
    then 
        info "${linkto} exists and is a file"
    elif [[ -d "${linkto}" ]];
    then
        info "${linkto} exists and is a directory"
    elif [[ -L ${linkto} ]];
    then
        info "${linkto} exists and is a symlink"
        ls -l "${linkto}" | indent
    else
        ln -s "${frompath}" "${linkto}"
        didItLink=$?
        if [[ "${didItLink}" -eq 0 ]];
        then
            pass "Created symlink from ${frompath} to ${linkto}"
        else
            fail "Failed to create symlink from ${frompath} to ${linkto}"
            exit "${didItLink}"
        fi
    fi

}

#--------------------------------------------------------------------
function installvimconfig()
{
    createdir "$HOME/.vim/files/backup"
    createdir "$HOME/.vim/files/swap"
    createdir "$HOME/.vim/files/undo"
    createdir "$HOME/.vim/files/info"
    createdir "$HOME/.local/share/nvim"
    createdir "$HOME/.config/nvim"
    createdir "$HOME/vim"
    #Vim config
    if [[ -f $HOME/.vimrc ]];
    then
        info ".vimrc exists in $HOME"
    else
        linkfile "$SCRIPTPATH/.vimrc" "$HOME/.vimrc"
    fi

    #Setup nvim also
    linkfile "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"
    linkfile "$HOME/.local/share/nvim/site" "$HOME/vim" 

    #Install vimplug
    vimplugurl="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs "${vimplugurl}" | indent

    # Install the plugins
    vim +PlugInstall
}

#--------------------------------------------------------------------
function installpackages()
{
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
    packagelist+=( "neovim" )
    packagelist+=( "git" )
    packagelist+=( "clang" )
    packagelist+=( "gcc" )
    packagelist+=( "cmake" )
    packagelist+=( "wget" )
    packagelist+=( "curl" )
    packagelist+=( "autoconf" )
    packagelist+=( "ninja-build" )
    packagelist+=( "python" )
    packagelist+=( "terminator" )
    packagelist+=( "tilix" )
    packagelist+=( "ripgrep" )
    packagelist+=( "byobu" )
    packagelist+=( "meld" )
    packagelist+=( "tigervnc-*" )
    packagelist+=( "xrdp" )

    if [[ -f "/etc/debian_version" ]];
    then

        packagelist+=( "build-essential" )
        packagelist+=( "python-dev" )
        packagelist+=( "shellcheck" )

    elif [[ -f "/etc/fedora-release" ]];
    then

        packagelist+=( "@development-tools" )
        packagelist+=( "ShellCheck" )
        packagelist+=( "python-devel" )
        packagelist+=( "python3-neovim" )

    fi

    packages=$( IFS=$' '; echo "${packagelist[*]}" )

    packageinstalllog="${LOGFILE}/package-install.log"
    set -x
    sudo ${package_manager} ${packages}  | tee "${packageinstalllog}" | indent
    didItInstall=${PIPESTATUS[0]}
    set +x
    if [[ "${didItInstall}" -ne 0 ]];
    then
        fail "Failed to install paackages - check ${packageinstalllog}"
        cat "${packageinstalllog}"
        exit "${didItInstall}"
    fi
}

#--------------------------------------------------------------------
function installrust()
{
    #install rust
    which rustc &> /dev/null
    if [[ $? -ne 0 ]];
    then
        info "rustc not found in path - installing"
        curl https://sh.rustup.rs -sSf | sh
    else
        pass "rustc is already present"
    fi
}

#--------------------------------------------------------------------
# Fuzzy file searcher
function installfzf()
{
    fzfpath="$HOME/.fzf"
    if [[ -d "${fzfpath}" ]]; then 
        info "Updating fzf already present at ${fzfpath}"
        git -C "${fzfpath}" pull --ff-only | indent
        yes | source "${fzfpath}/install" | indent
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git "${fzfpath}" | indent
        ${fzfpath}/install | indent
    fi
}

#--------------------------------------------------------------------
function installFonts()
{
    fontinstalllog="/tmp/FontInstall.log"
    fontdir="$HOME/.local/share/fonts"
    createdir "${fontdir}"
    downloadto="/tmp/FiraCode.zip"
    wget -O "${downloadto}" "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip" | tee "${fontinstalllog}" | indent
    unzip -o "${downloadto}" -d "${fontdir}" | tee -a "${fontinstalllog}" | indent
    if [[ ${PIPESTATUS[0]} -ne 0 ]];
    then
        fail "Failed to installed fonts"
        exit 1
    else
        rm -f "${downloadto}"
        pass "Installed fonts"
    fi
}

#--------------------------------------------------------------------
function installprompt()
{
    #1. Install liquidpromt as a backup
    pathtolp="$HOME/liquidprompt"
    logoutput="${LOGFILE}/liquidprompt-install.log"
    gitExitCode=0
    if [[ -d "${pathtolp}" ]];then
        info "${pathtolp} already exists - updating"
        git -C "${pathtolp}" pull --ff-only > "${logoutput}"
        gitExitCode=$?
    else
        git clone "https://github.com/nojhan/liquidprompt.git" "${pathtolp}" > "${logoutput}"
        gitExitCode=$?
    fi

    if [[ "${gitExitCode}" -ne 0 ]];
    then
        fail "Liquid prompt install/update failed"
        cat "${logoutput}"
        exit $gitExitCode
    else
        pass "Liquidprompt updated/installed"
    fi

    # Liquidprompt config file
    if [[ -f ~/.config/liquidpromptrc ]]; then
        info "Liquidpromptrc exists!"
    else
        linkfile "${SCRIPTPATH}/liquidpromptrc" "$HOME/.config/liquidpromptrc"
    fi

    #2. Install Startship 
    info "Installing startship.rs"
    sh -c "$(curl -fsSL https://starship.rs/install.sh)"
    linkfile "$SCRIPTPATH/starship.toml" "$HOME/.config/starship.toml"
    info "Reloading bashrc"
    source "$HOME/.bashrc"
}

#--------------------------------------------------------------------
function installBashPrefrences()
{
    #$USER bash preferences
    bashrcfile="$HOME/.bashrc"
    grep -n --color "bashUserPost" "${bashrcfile}" | indent
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        linkfile "$SCRIPTPATH/.bashUserPost" "$HOME/.bashUserPost"
        echo "source ~/.bashUserPost" >> "${bashrcfile}"
        pass "Installed .bashUserPost"
        
        info "Reloading bashrc"
        source "$HOME/.bashrc"
    else
        info "bashUserPost is already sourced in bashrc"
    fi
}

#--------------------------------------------------------------------
function installXResources()
{
    #Xresources
    Xresourcefile=".Xresources"
    pathtoXresources="$HOME/$Xresourcefile"
    repofile="$SCRIPTPATH/$Xresourcefile"

    if [[ -f "${pathtoXresources}" ]];then
        info "${pathtoXresources} exists"
    else
        linkfile "${repofile}" "${pathtoXresources}" 
    fi
}

#--------------------------------------------------------------------
function installGitConfig()
{
    #Git Config
    linkfile "$SCRIPTPATH/.gitconfig" "$HOME/.gitconfig"

    git config --get user.name | indent
    username=${PIPESTATUS[0]}
    if [[ $username -ne 0 ]];
    then
        read -p 'git user.name ' gitconfigusername
        set -x
        git config --global user.name "${gitconfigusername}"
        set +x
    else
        info "git.user is configured"
    fi

    git config --get user.email | indent
    useremail=${PIPESTATUS[0]}
    if [[ $useremail -ne 0 ]];
    then
        read -p 'git user.email ' gitconfiguseremail
        set -x
        git config --global user.email "${gitconfiguseremail}"
        set +x
    else
        info "git.email is configured"
    fi
}

#--------------------------------------------------------------------
function installVncXstartup()
{
    createdir "$HOME/.vnc"
    linkfile "${SCRIPTPATH}/xstartup" "${HOME}/.vnc/xstartup"
}

#--------------------------------------------------------------------
function installXfceThemes()
{
    # Only install on debian
    checkfordebian="/etc/debian_version" 
    if [[ -f "${checkfordebian}" ]];
    then
        logfile="$LOGFILE/xfceThemes.log"
        installThemeTo="$HOME/.themes"
        downloadTo="/tmp/Nordic-darker.tar.xz"
        info "Installing xfce nice things"
        createdir "${installThemeTo}"
        wget -O "${downloadTo}" "https://github.com/EliverLara/Nordic/releases/download/v1.9.0/Nordic-darker.tar.xz"
        tar -xvf "${downloadTo}" -C "${installThemeTo}" | indent > "${logfile}"
        extractcode=${PIPESTATUS[0]}

        if [[ $extractcode -ne 0 ]];
        then
            fail "Could not install themes"
            exit $extractcode
        else
            rm -f "${downloadTo}"
        fi

        installIconsTo="$HOME/.icons"
        createdir "${installIconsTo}"
        downloadTo="/tmp/FlatMix"
        createdir "${downloadTo}"

        iconstoinstall="Flat-Remix-Yellow-Light" #This is a dir in this git repo
        
        git clone --depth 1 "https://github.com/daniruiz/flat-remix.git" "${downloadTo}"
        rm -rf "${installIconsTo}/${iconstoinstall}"
        mv "${downloadTo}/${iconstoinstall}" "${installIconsTo}/${iconstoinstall}"
        extracticonscode=$?
        if [[ $extracticonscode -ne 0 ]];
        then
            fail "Could not install icons"
            exit $extracticonscode
        else
            rm -rf "${downloadTo}"
            # Update the icon cache
            info "Updating icon cache"
            gtk-update-icon-cache "${installIconsTo}/${iconstoinstall}" | indent 
            # gsettings set org.gnome.desktop.interface icon-theme "${iconstoinstall}"
            info "setting icons to ${iconstoinstall}"
            xfconf-query -c xsettings -p /Net/IconThemeName -s ${iconstoinstall}
        fi

    else
        info "OS is not debian - skipping xfce theme installs"
    fi
}

#-------------------------------------------------------------------
function installAlacrittyConfig()
{
    createdir "${HOME}/.config/alacritty"
    linkfile "${SCRIPTPATH}/alacritty.yml" "${HOME}/.config/alacritty/alacritty.yml"
}

#-------------------------------------------------------------------
function installVSCode()
{
    checkfordebian="/etc/debian_version"
    checkforfedora="/etc/fedora-release"
    if [[ -f "${checkfordebian}" ]];
    then
        info "VSCode install - debian"
        set -x
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt install apt-transport-https
        sudo apt update
        sudo apt install code
        set +x

    elif [[ -f "${checkforfedora}" ]];
    then
        info "VSCode install - fedora"
        set -x
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf check-update
        sudo dnf install code
        set +x
    else
        info "OS is other than debian/fedora skip vs code install"
    fi

}

#-------------------------------------------------------------------
function installxrdpUsers()
{
    info "Adding user to xrdp and ssl-cert"
    sudo adduser xrdp ssl-cert
    sudo systemctl restart xrdp
    info "TODO: manually link startwm.sh from dotfiles to /etc/xrdp"
}

#--------------------------------------------------------------------
function main()
{
    installXResources
    installpackages
    installrust
    installfzf
    installFonts
    installprompt
    installvimconfig
    installBashPrefrences
    installGitConfig
    installVncXstartup
    installXfceThemes
    installAlacrittyConfig
    installVSCode
    installxrdpUsers

    source $HOME/.bashrc
    pass "Done, Done & Donzel Washington"
}

main
