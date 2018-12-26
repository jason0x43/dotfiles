#!/usr/bin/bash

cd

name=$(uname -a)
npm_command=npm

if [[ name =~ "Ubuntu" ]]; then
    # neovim
    sudo add-apt-repository ppa:neovim-ppa/stable
    # fzf
    sudo add-apt-repository ppa:fmarier/ppa

    # docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

    # nodejs
    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

    sudo apt update

    # general utilities
    sudo apt install -y neovim fzf zsh nodejs npm
    
    # docker
    sudo apt install -y \
        apt-transport-https \
        ca-certificates curl \
        software-properties-common \
        docker-ce
    sudo usermod -aG docker ${USER}

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
