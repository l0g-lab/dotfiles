#!/bin/bash
#
# This script will put the dotfiles into place
set -e
echo "====== dotfiles installer script ======"

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
	if [ -f ~/.Xdefaults ]; then cp ~/.Xdefaults ~/.Xdefaults.bak; fi
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
	if [ -f ~/.tmux.conf ]; then cp ~/.tmux.conf ~/.tmux.conf.bak; fi
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
	if [ -f ~/.tmux.conf ]; then cp ~/.spectrwm.conf ~/.spectrwm.bak; fi
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
	if [ -f ~/.config/i3 ]; then cp -r ~/.config/i3 ~/.config/i3.bak; fi
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
	if [ -f ~/.config/fluxbox ]; then cp -r ~/.config/fluxbox ~/.config/fluxbox.bak; fi
	cp -rf fluxbox ~/.config/.
	echo "setup complete:	fluxbox config"
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

# Moving vim config into place
read -p "Install vim config? (y/n): " response
if [[ "$response" == "y" ]]; then
	if [ -f ~/.vimrc ]; then cp -r ~/.vimrc ~/.vimrc.bak; fi
	cp -rf vimrc ~/.vimrc
	echo "setup complete:	vim config"
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."
fi

# Moving vim config into place
read -p "Install vim config? (y/n): " response
if [[ "$response" == "y" ]]; then
	if [ -f ~/.vimrc ]; then cp -r ~/.gitconfig ~/.gitconfig.bak; fi
	cp -rf gitconfig ~/.gitconfig
	echo "setup complete:	git config"
elif [[ "$response" == "n" ]]; then
	echo "Skipping..."
else
	echo "Invalid input, skipping..."

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
