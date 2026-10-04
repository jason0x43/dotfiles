#
# Defines environment variables before .zshrc is sourced
#
# This is the real content of ~/.zshenv. It exists here because ~/.zshenv is
# just use to set ZDOTDIR.
#
# This file should be kept light and fast. Anything that's slow or involves
# user interaction should go in zshrc.
#

source $ZDOTDIR/common.zsh

# Language
# ----------------------------------------------------------------------------
[[ -z "$LANG" ]] && export LANG=en_US.UTF-8
[[ -z "$LC_ALL" ]] && export LC_ALL=$LANG

# Cache and temp files
# ----------------------------------------------------------------------------
[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"
[[ -d "$ZCACHEDIR" ]] || mkdir -p "$ZCACHEDIR"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"

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

if [[ -d /usr/local/bin ]]; then
    path=(
        /usr/local/bin
        $path
    )
fi

# Homebrew needs to be in the path for later tests to work
if [[ -d $HOMEBREW_BASE ]]; then
    path=(
        $HOMEBREW_BASE/bin
        $HOMEBREW_BASE/sbin
        $path
    )
fi

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

# pkg-config
# --------------------------------------------------------------------------
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

# Path
# ----------------------------------------------------------------------------

# Use Bootsnap to speed up repeated brew calls
if [[ -d $HOMEBREW_BASE ]]; then
    export HOMEBREW_BOOTSNAP=1
fi

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

# Rust
if [[ -f $HOME/.cargo/env ]]; then
    . $HOME/.cargo/env
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
        $HOMEBREW_BASE/opt/python3/libexec/bin
        $path
    )
fi

# Bun
if [[ -d $HOME/.bun/bin ]]; then
    export BUN_INSTALL="$HOME/.bun"
    path=(
        $BUN_INSTALL/bin
        $path
    )
fi

# corepack
if (( $+commands[corepack] )); then
    export COREPACK_ENABLE_AUTO_PIN=0
fi

# ripgrep
if (( $+commands[rg] )); then
    export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep
fi

# Add user dirs to path
# --------------------------------------------------------------------------
path=($DOTFILES/bin $path)

# From user-level packages
if [[ -d $HOME/.local/bin ]]; then
    path=($HOME/.local/bin $path)
fi

# From go install
if [[ -d $GOPATH ]]; then
    path=($GOPATH/bin $path)
fi

# Local apps
if [[ -d $HOME/bin ]]; then
    path=($HOME/bin $path)
fi

# Local apps
if [[ -d $HOME/Applications ]]; then
    path=($HOME/Applications $path)
fi

# Local config
# --------------------------------------------------------------------------
[[ -f $ZDOTDIR/local/zshenv ]] && source $ZDOTDIR/local/zshenv

# Remember the path so .zprofile can restore its order after path_helper
typeset -ga _zshenv_path=($path)
