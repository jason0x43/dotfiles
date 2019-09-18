#!/bin/bash

dotfiles=$HOME/.dotfiles
configdir=$HOME/.config
cachedir=$HOME/.local/share
cd $HOME

# By default, the script only outputs what it *would* do. Use the '-g' ("go")
# option to actually perform the initialization steps.
if [[ "$1" != "-g" ]]; then
	echo "This script creates cache directories and links dotfiles into your home directory."
	echo "This is a dry run. Use '-g' to actually initialize."
fi

if [[ "$1" == "-g" ]]; then
	# Create a directory
	function makedir {
		[[ ! -d $1 ]] && mkdir -p $1
	}

	# Create a symlink
	function link {
		[[ ! -r $2 ]] && ln -s $1 $2
	}

	# Fix terminal definition so C-H works properly in neovim
	function fixterm {
		infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
		tic /tmp/$TERM.ti
		rm /tmp/$TERM.ti
	}
else
	function makedir {
		echo "mkdir $1"
	}

	function link {
		echo "ln -s $1 -> $2"
	}

	function fixterm {
		echo "infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti"
		echo "tic /tmp/$TERM.ti"
		echo "rm /tmp/$TERM.ti"
	}
fi

for f in $(ls $dotfiles/home); do
	link $dotfiles/$f $HOME/.$(basename $f)
done

link $dotfiles/vim $HOME/.vim

makedir $cachedir/tmux/resurrect
makedir $cachedir/vim/session
makedir $cachedir/zsh

makedir $configdir
link $dotfiles/vim $configdir/nvim

# Fix the terminal definition so that C-H works properly in neovim. This
# function may also need to be run for the tmux terminal type.
fixterm
