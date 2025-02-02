#!/bin/bash
#
# This script will put the dotfiles into place
set -e

# Check distro and install packages
## Get package list
PACKAGES=$(cat ./i3/startup | awk '{ print $1 }')

echo "====== dotfiles installer script ======"

## Install packages
read -p "Try to install packages? (y/n): " response
if [[ "$response" == "y" ]]; then
	echo "Installing Packages"
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
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

# Moving bashrc into place
read -p "Install bashrc? (y/n): " response
if [[ "$response" == "y" ]]; then
	cp ~/.bashrc ~/.bashrc.bak
	cp -f ./bashrc ~/.bashrc
	echo "setup complete:	.bashrc"
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

# Moving Xdefaults into place
read -p "Install Xdefaults? (y/n): " response
if [[ "$response" == "y" ]]; then
	cp ~/.Xdefaults ~/.Xdefaults.bak
	cp -f ./Xdefaults ~/.Xdefaults
	echo "setup complete:	.Xdefaults"
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

# Moving tmux.conf into place
read -p "Install tmux.conf? (y/n): " response
if [[ "$response" == "y" ]]; then
	cp ~/.tmux.conf ~/.tmux.conf.bak
	cp -f ./tmux.conf ~/.tmux.conf
	echo "setup complete:	.tmux.conf"
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

# Moving spectrwm.conf into place
read -p "Install spectrwm.conf? (y/n): " response
if [[ "$response" == "y" ]]; then
	cp ~/.spectrwm.conf ~/.spectrwm.bak
	cp -f ./spectrwm.conf ~/.spectrwm.conf
	echo "setup complete:	.spectrwm.conf"
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

# Moving i3wm config into place
read -p "Install i3 config? (y/n): " response
if [[ "$response" == "y" ]]; then
	cp -r ~/.config/i3 ~/.config/i3.bak
	cp -rf i3 ~/.config/.
	echo "setup complete:	i3 config"
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

# Moving fluxbox config into place
read -p "Install fluxbox config? (y/n): " response
if [[ "$response" == "y" ]]; then
	cp -r ~/.config/fluxbox ~/.config/fluxbox.bak
	cp -rf fluxbox ~/.config/.
	echo "setup complete:	fluxbox config"
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

# Move local scripts into place
read -p "Install local scripts? (y/n): " response
if [[ "$response" == "y" ]]; then
	cp -f local/bin/* ~/.local/bin/.
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

echo "====== DONE ======"
