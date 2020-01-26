#!/bin/zsh

dotfiles=$HOME/.dotfiles
configdir=$HOME/.config
cachedir=$HOME/.local/share
cd $HOME

if ! hash zsh; then
	echo "Step 1: install zsh"
	exit 1
fi

if ! hash brew; then
	echo "Step 2: install homebrew"
	echo '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
	exit 1
fi

# Install some baseline packages
brew_packages=(
	'bat'
	'direnv'
	'fd'
	'fzf'
	'gawk'
	'git'
	'git-delta'
	'jenv'
	'neovim'
	'node'
	'nodenv'
	'pyenv'
	'ripgrep'
	'tmux'
)
echo ">>> Checking for missing brew packages..."
installed_packages=("${(@f)$(brew ls --versions $brew_packages | awk '{ print $1 }')}")
for pkg in $brew_packages; do
	if ((! $installed_packages[(Ie)$pkg])); then
		echo ">>> Installing $pkg..."
		brew install $pkg
	fi
done

# Create a directory
function makedir {
	if [[ ! -d $1 ]]; then
		echo ">>> Creating $1/..."
		mkdir -p $1
	fi
}

# Create a symlink
function link {
	if [[ ! -r $2 ]]; then
		echo ">>> Creating $1 -> $2..."
		ln -s $1 $2
	fi
}

# Fix terminal definition so C-H works properly in neovim
function fixterm {
	kbs=$(infocmp $TERM | grep -o 'kbs=[^,]\+')
	if [[ $kbs =~ "kbs=^[hH]" ]]; then
		echo ">>> Fixing backspace code in terminfo..."
		infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
		tic /tmp/$TERM.ti
		rm /tmp/$TERM.ti
	fi
}

function setup_jenv {
	makedir $HOME/.jenv/versions

	if [[ -x /usr/libexec/java_home ]]; then
		sys_home=$(/usr/libexec/java_home)
		if [[ ! $HOME/.jenv/versions/system -ef $sys_home ]] then
			echo ">>> Creating system link for jenv..."
			ln -sf $sys_home $HOME/.jenv/versions/system
		fi
	fi
}

for f in $(ls $dotfiles/home); do
	link $dotfiles/home/$f $HOME/.$(basename $f)
done

for f in $(ls $dotfiles/config); do
	link $dotfiles/config/$f $HOME/.config/$(basename $f)
done

link $dotfiles/vim $HOME/.vim

makedir $cachedir/tmux/resurrect
makedir $cachedir/vim/session
makedir $cachedir/vim/swap
makedir $cachedir/vim/backup
makedir $cachedir/vim/undo
makedir $cachedir/zsh

makedir $configdir
link $dotfiles/vim $configdir/nvim

# Fix the terminal definition so that C-H works properly in neovim. This
# function may also need to be run for the tmux terminal type.
fixterm

setup_jenv

echo ">>> Done"
