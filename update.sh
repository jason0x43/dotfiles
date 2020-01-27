#!/bin/zsh

autoload colors; colors

# Log output
function log {
	msg=$1
	echo "$fg_bold[green]>>>$reset_color $fg_bold[white]$msg$reset_color"
}

# Log output
function logSub {
	msg=$1
	echo "$fg_bold[blue]>>>$reset_color $fg_bold[white]$msg$reset_color"
}

# Log error output
function err {
	msg=$1
	echo "$fg_bold[red]>>>$reset_color $fg_bold[white]$msg$reset_color"
}

# Create a directory
function makedir {
	if [[ ! -d $1 ]]; then
		log "Creating $1/..."
		mkdir -p $1
	fi
}

# Create a symlink
function link {
	if [[ ! -r $2 ]]; then
		log "Creating $1 -> $2..."
		ln -s $1 $2
	fi
}

# Fix terminal definition so C-H works properly in neovim
function fixterm {
	kbs=$(infocmp $TERM | grep -o 'kbs=[^,]\+')
	if [[ $kbs =~ "kbs=^[hH]" ]]; then
		log "Fixing backspace code in terminfo..."
		infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
		tic /tmp/$TERM.ti
		rm /tmp/$TERM.ti
	fi
}

dotfiles=$HOME/.dotfiles
configdir=$HOME/.config
cachedir=$HOME/.local/share
cd $HOME

# basic profile setup
# ----------------------------------------------------------

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

# homebrew
# ----------------------------------------------------------
if ! hash brew; then
	log "Installing homebrew..."
	usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	rehash
fi

log "Checking for missing brew packages..."
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
installed_packages=("${(@f)$(brew ls --versions $brew_packages | awk '{ print $1 }')}")
for pkg in $brew_packages; do
	if ((! $installed_packages[(Ie)$pkg])); then
		log "Installing $pkg..."
		brew install $pkg
	fi
done

log "Updating installed brew packages..."
brew upgrade

log "Updating installed brew casks..."
brew cask upgrade

# zsh
# ----------------------------------------------------------
if [[ -n $ZPLUGDIR ]]; then
	log "Updating zsh plugins..."
	cd $ZPLUGDIR
	for org in *; do
		cd $org 
		for plugin in *; do
			cd $plugin
			head=$(git rev-parse HEAD)
			git pull -q --recurse-submodules
			git submodule update --remote
			if [[ $(git rev-parse HEAD) != $head ]]; then 
				logSub "Updated $org/$plugin"
			fi
			cd ..
		done
		cd ..
	done
fi

# python
# ----------------------------------------------------------

if hash pip3; then
	log "Updating global python3 packages..."
	pip3 install -U pip setuptools pynvim > /dev/null
fi
if hash pip2; then
	log "Updating global python2 packages..."
	PYTHONWARNINGS=ignore:DEPRECATION pip2 install -U pip setuptools pynvim > /dev/null
fi

# jenv
# ----------------------------------------------------------

if [[ ! -d $HOME/.jenv/versions ]]; then
	log "Setting up jenv..."
	makedir $HOME/.jenv/versions
fi

if [[ -x /usr/libexec/java_home ]]; then
	sys_home=$(/usr/libexec/java_home)
	if [[ ! $HOME/.jenv/versions/system -ef $sys_home ]] then
		log "Updating system link for jenv..."
		ln -sf $sys_home $HOME/.jenv/versions/system
	fi
fi

# npm
# ----------------------------------------------------------

if hash npm; then
	log "Updating global npm modules..."
	# get list of outdated global packages
	mods=$(npm --registry=https://registry.npmjs.org outdated -g --parseable)
	for mod in $mods; do
		# extract current and latest fields
		array=(${(@s/:/)mod})
		currentPkg=$array[2]
		latestPkg=$array[4]

		# extract current and latest versions, minus any prerelease tags
		currentVerParts=(${(@s/@/)currentPkg})
		currentVer=$currentVerParts[2]
		latestVerParts=(${(@s/@/)latestPkg})
		latestVer=$latestVerParts[2]

		if [[ $latestVer == 'linked' ]]; then
			logSub "Skipping $latestPkg"
			continue
		fi

		# read versions into arrays
		current=(${(@s/./)currentVer})
		latest=(${(@s/./)latestVer})

		# if latest is newer than current, install latest
		if (( latest[0] > current[0] )) || {
			(( latest[0] == current[0] )) &&
			(( latest[1] > current[1] )) || {
				(( latest[0] == current[0] )) &&
				(( latest[1] == current[1] )) &&
				(( latest[2] > current[2] ));
			};
		}; then
			logSub "Installing $latestPkg..."
			npm install --registry=https://registry.npmjs.org --progress=false -g $latestPkg > /dev/null
		fi
	done
fi

# tmux
# ----------------------------------------------------------
if [[ -n $TMUX_PLUGIN_MANAGER_PATH ]]; then
	log "Updating tmux plugins..."
	cd $TMUX_PLUGIN_MANAGER_PATH
	for plugin in *; do
		cd $plugin 
		head=$(git rev-parse HEAD)
		git pull -q --recurse-submodules
		git submodule update --remote -q
		if [[ $(git rev-parse HEAD) != $head ]]; then 
			logSub "Updated $plugin"
		fi
		cd ..
	done
fi

# vim
# ----------------------------------------------------------
if [[ -a $HOME/.vim/autoload/plug.vim ]]; then
	log "Updating vim-plug..."
	cd $HOME/.vim/autoload
	existing=$(<plug.vim)
	current=$(curl -s https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim)
	if [[ "$existing" != "$current" ]]; then
		mv plug.vim plug.old
		echo -E "$current" > plug.vim
	fi

	log "Updating vim plugins..."
	cd $CACHEDIR/vim/plugins
	for plugin in *; do
		cd $plugin 
		head=$(git rev-parse HEAD)
		git pull -q --recurse-submodules
		if (( $? != 0 )); then 
			err "Problem updating $plugin"
		else
			# If the current head is different than the original head,
			# check for a package.json
			if [[ $(git rev-parse HEAD) != $head ]]; then 
				logSub "Updating $plugin..."
				if [[ -e package.json ]]; then
					if [[ -e yarn.lock ]]; then
						yarn install --registry=https://registry.npmjs.org --frozen-lockfile --silent
					else
						npm install --registry=https://registry.npmjs.org --silent
					fi
				fi
			fi
		fi
		cd ..
	done
fi

log "Done"
