#!/bin/bash

function makeRelative {
	source=$1
	target=$2
	prefix=$source
	relative=""

	while [[ "${target#$prefix}" == "${target}" ]]; do
		# no match, means that candidate common part is not correct
		# go up one level (reduce common part)
		prefix="$(dirname $prefix)"
		# and record that we went back, with correct / handling
		if [[ -z $relative ]]; then
			relative=".."
		else
			relative="../$relative"
		fi
	done

	if [[ $prefix == "/" ]]; then
		# special case for root (no common path)
		relative="$relative/"
	fi

	# Compute the non-common part
	forward_part="${target#$prefix}"

	# Combine everything
	if [[ -n $relative ]] && [[ -n $forward_part ]]; then
		relative="$relative$forward_part"
	elif [[ -n $forward_part ]]; then
		# extra slash removal
		relative="${forward_part:1}"
	fi

	echo $relative
}

cd $(dirname $BASH_SOURCE)
dotfiles=$(makeRelative $HOME `pwd`)
cachedir=~/.cache

# Support a '-t' command line argument that runs the script in test mode (i.e.,
# no changes are made to the filesystem)
test=0
if [[ "$1" == "-t" ]]; then
	test=1
fi

if [[ "$1" == "-h" ]]; then
	echo "usage: $0 [-t] [-h]"
	echo "   -t   test mode (just show what would be done)"
	echo "   -h   show this message"
	echo
	echo "This script creates cache directories and links dotfiles into your home directory."
	exit 0
fi

if [[ $test == 1 ]]; then
	function makedir {
		echo "mkdir $1"
	}

	function link {
		echo "ln -s $1 -> $2"
	}
else
	function makedir {
		[[ ! -d $1 ]] && mkdir -p $1
	}

	function link {
		[[ ! -r $2 ]] && run ln -s $1 $2
	}
fi

for f in $(ls home/*); do
	link $dotfiles/$f ~/.$(basename $f)
done

link $dotfiles/vim ~/.vim

makedir $cachedir/tmux/resurrect
makedir $cachedir/vim/session
makedir $cachedir/zsh
