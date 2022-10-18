#
# Defines environment variables before .zshrc is sourced
#
# This file should be kept light and fast. Anything that's slow or involves
# user interaction should go in zshrc.
#

source $ZDOTDIR/common.zsh

# Language
# ----------------------------------------------------------------------------
[[ -z "$LANG" ]] && eval "$(locale)"
[[ -z "$LANG" ]] && export LANG=en_US.UTF-8
[[ -z "$LC_ALL" ]] && export LC_ALL=$LANG

# Cache and temp files
# ----------------------------------------------------------------------------
[[ -d "$CACHEDIR" ]] || mkdir -p "$CACHEDIR"
[[ -d "$ZCACHEDIR" ]] || mkdir -p "$ZCACHEDIR"
[[ -d "$DATADIR" ]] || mkdir -p "$DATADIR"
[[ -d "$ZFUNCDIR" ]] || mkdir -p "$ZFUNCDIR"

if [[ -d "$TMPDIR" ]]; then
	export TMPPREFIX=${TMPDIR%/}/zsh
	[[ -d "$TMPPREFIX" ]] || mkdir -p "$TMPPREFIX"
fi

# Plugins
# ----------------------------------------------------------------------------
if [[ ! -d "$ZPLUGDIR" ]]; then
    mkdir -p "$ZPLUGDIR"
fi

# General paths
# ----------------------------------------------------------------------------
typeset -gU mailpath path

# Path
# --------------------------------------------------------------------------
if [[ -d /usr/local/bin ]]; then
	path=(
		/usr/local/bin
		$path
	)
fi

path=(
	$HOME/Applications
	$DOTFILES/bin
	$HOME/.local/bin
	$HOMEBREW_BASE/bin
	$HOMEBREW_BASE/sbin
	$path
)

# Groovy
# ----------------------------------------------------------------------------
if [[ -z "$GROOVY_HOME" ]]; then
	export GROOVY_HOME=$HOMEBREW_BASE/opt/groovy/libexec
fi

# Java
# ----------------------------------------------------------------------------
if [[ -z "$JAVA_HOME" ]]; then
	if [[ -x /usr/libexec/java_home ]]; then
		export JAVA_HOME=`/usr/libexec/java_home -v 14 2> /dev/null`
	fi
fi
export PATH_TO_FX=$HOME/Development/libs/javafx-sdk-11.0.2/lib
# Node
# ----------------------------------------------------------------------------
if [[ -e $HOME/.config/ssl/ca.pem ]]; then
	export NODE_EXTRA_CA_CERTS=$HOME/.config/ssl/ca.pem
fi

# Go
# ----------------------------------------------------------------------------
if (( $+commands[go] )); then
	case "$OSTYPE" in
		darwin*) export GOPATH=$HOME/Code/go ;;
		linux*)  export GOPATH=$HOME/go ;;
	esac
fi

# Android
# ------------------------------------------------------------------------
if (( $+commands[android] )); then
	export ANDROID_HOME=`echo $(which android)(:A:h:h)`
fi

# Terminal
# --------------------------------------------------------------------------
if [[ -z $TERM_PROGRAM ]]; then
	if [[ -n $GNOME_TERMINAL_SCREEN ]]; then
		export TERM_PROGRAM=gnome-terminal
	elif [[ -n $KITTY_LISTEN_ON ]]; then
		export TERM_PROGRAM=kitty
	fi

	# https://github.com/kovidgoyal/kitty/issues/1645#issuecomment-496221126 
	export KITTY_DISABLE_WAYLAND=1
fi

# Tmux
# --------------------------------------------------------------------------
export TMUX_PLUGIN_MANAGER_PATH="$DATADIR/tmux/tmux-plugins"

# pkg-config
typeset -U pkg_config_path

if [[ -d $HOMEBREW_BASE/opt/openssl ]]; then
	pkg_config_path=(
		$HOMEBREW_BASE/opt/openssl/lib/pkgconfig
		$pkg_config_path
	)
fi

if [[ -d $HOMEBREW_BASE/opt/icu4c ]]; then
	pkg_config_path=(
		$HOMEBREW_BASE/opt/icu4c/lib/pkgconfig
		$pkg_config_path
	)
fi

export PKG_CONFIG_PATH=$(print -R ${(j|:|)pkg_config_path})

# LLVM
# Put LLVM at the end of the path to avoid overriding Xcode's LLVM in projects
# that use it (this may not be sufficient)
if [[ -d $HOMEBREW_BASE/opt/llvm ]]; then
	path=(
		$path
		$HOMEBREW_BASE/opt/llvm/bin
	)
fi

# Ruby
if [[ -d $HOMEBREW_BASE/opt/ruby ]]; then
	path=(
		$HOMEBREW_BASE/opt/ruby/bin
		$path
	)
fi
if [[ -d $HOMEBREW_BASE/lib/ruby/gems/3.0.0 ]]; then
	path=(
		$HOMEBREW_BASE/lib/ruby/gems/3.0.0/bin
		$path
	)
fi

# Rust
if [[ -d $HOME/.cargo/bin ]]; then
	path=(
		$HOME/.cargo/bin
		$path
	)
fi

# sqlite3
if [[ -d $HOMEBREW_BASE/opt/sqlite3 ]]; then
	path=(
		$HOMEBREW_BASE/opt/sqlite3/bin
		$path
	)
fi

# Python
if [[ -d $HOMEBREW_BASE/opt/python3 ]]; then
	# Put python at the end of the path since some of its programs, like pip,
	# will eventually be overridden with things in $HOMEBREW_BASE/bin
	# https://discourse.brew.sh/t/pip-install-upgrade-pip-breaks-pip-when-installed-with-homebrew/5338
	path=(
		$path
		$HOMEBREW_BASE/opt/python3/libexec/bin
	)
fi

if [[ -d $HOME/.poetry/bin ]]; then
	path=(
		$path
		$HOME/.poetry/bin
	)
fi

if (( $+commands[pdm] )); then
	function () {
		local pdm_dirs=($HOMEBREW_BASE/Cellar/pdm/*)
		local pdm_dir=${pdm_dirs[-1]}
		local lib_dirs=($pdm_dir/libexec/lib/*)
		local lib_dir=${lib_dirs[-1]}
		if [[ -z $PYTHONPATH ]]; then
			export PYTHONPATH=$lib_dir/site-packages/pdm/pep582
		elif [[ ! $PYTHONPATH =~ $lib_dir ]]; then 
			export PYTHONPATH=$lib_dir/site-packages/pdm/pep582:$PYTHONPATH
		fi
	}
fi

# Go
if (( $+commands[go] )) && [[ -n $GOPATH ]]; then
	path=(
		$GOPATH/bin
		$path
	)
fi

# PHP
if [[ -d $HOMEBREW_BASE/opt/php@7.1/bin ]]; then
	path=(
		$HOME/.composer/vendor/bin
		$path
		$HOMEBREW_BASE/opt/php@7.1/bin
		$HOMEBREW_BASE/opt/php@7.1/sbin
	)
fi

# TeX
if [[ -e $HOMEBREW_BASE/texlive ]]; then 
	path=(
		$path
		$HOMEBREW_BASE/texlive/2019/bin/x86_64-darwin
	)
fi

# VMware
if [[ -e /Applications/VMware\ Fusion.app/Contents/Library ]]; then
	path=(
		$path
		/Applications/VMware\ Fusion.app/Contents/Library
	)
fi

# Deno
if [[ -d $HOME/.deno/bin ]]; then
	path=(
		$path
		$HOME/.deno/bin
	)
fi

# Bun
if [[ -d $HOME/.bun/bin ]]; then
    export BUN_INSTALL="$HOME/.bun"
	path=(
		$path
		$BUN_INSTALL/bin
	)
fi

# Homebrew
# ----------------------------------------------------------------------------
# Use Bootsnap to speed up repeated brew calls
export HOMEBREW_BOOTSNAP=1

# Local config
# --------------------------------------------------------------------------
[[ -f $ZCONFDIR/zshenv ]] && source $ZCONFDIR/zshenv

# Disable global zprofile, which messes with the path
unsetopt GLOBAL_RCS

# vim:shiftwidth=4:tabstop=4:noexpandtab