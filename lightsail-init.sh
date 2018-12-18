#!/usr/bin/bash

cd

name=$(uname -a)
npm_command=npm

if [[ name =~ "Ubuntu" ]]; then
	# neovim
	sudo add-apt-repository ppa:neovim-ppa/stable
	# fzf
	sudo add-apt-repository ppa:fmarier/ppa
	sudo apt update
	sudo apt install neovim
	sudo apt install fzf
	sudo apt install zsh
	sudo apt install nodejs
	sudo apt install npm
	npm_command=sudo npm
fi

$npm_command install -g npm

if [[ ! -d .config ]]; then
	mkdir .config
fi

if [[ ! -d .dotfiles ]]; then
	git clone https://github.com/jason0x43/dotfiles .dotfiles
fi

ln -sr .dotfiles/home/zshrc .zshrc
ln -sr .dotfiles/home/zshenv .zshenv
ln -sr .dotfiles/home/tmux.conf .tmux.conf
ln -sr .dotfiles/vim .vim
ln -sr .dotfiles/vim .config/nvim
