#!/bin/bash
#
# This script will put the dotfiles into place
set -e

# Check distro and install packages
## Get package list
PACKAGES=$(cat ./i3/startup | awk '{ print $1 }')

## Install packages
if [[ -f /etc/os-release ]]; then
    . /etc/os-release

    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        echo "Detected Ubuntu/Debian"
        sudo apt update
		sudo apt install -y $PACKAGES
    elif [[ "$ID" == "fedora" ]]; then
        echo "Detected Fedora"
        sudo dnf install -y $PACKAGES
    elif [[ "$ID" == "arch" ]]; then
        echo "Detected Arch"
        sudo pacman -S --noconfirm $PACKAGES
    else
        echo "Unsupported distribution: $ID. Will need to manually install packages listed in ~/.local/config/i3/startup"
    fi
else
    echo "Could not detect the distribution. Will need to manually install packages listed in ~/.local/config/i3/startup"
fi

# Moving bashrc into place
cp -f ./bashrc ~/.bashrc
echo "setup complete:	.bashrc"

# Moving Xdefaults into place
cp -f ./Xdefaults ~/.Xdefaults
echo "setup complete:	.Xdefaults"

# Moving tmux.conf into place
cp -f ./tmux.conf ~/.tmux.conf
echo "setup complete:	.tmux.conf"

# Moving spectrwm.conf into place
cp -f ./spectrwm.conf ~/.spectrwm.conf
echo "setup complete:	.spectrwm.conf"

# Moving i3wm config into place
cp -rf i3 ~/.config/.
echo "setup complete:	i3 config"

# Moving fluxbox config into place
cp -rf fluxbox ~/.config/.
echo "setup complete:	fluxbox config"

# Move local scripts into place
cp -f local/bin/* ~/.local/bin/.
