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

# Go
# ----------------------------------------------------------------------------
case "$OSTYPE" in
    darwin*) export GOPATH=$HOME/Code/go ;;
    linux*)  export GOPATH=$HOME/go ;;
esac

# Path
# ----------------------------------------------------------------------------
# Entries marked (N) are only added if they exist
typeset -gU mailpath path
path=(
    $HOME/Applications(N)
    $HOME/bin(N)
    $GOPATH/bin(N)
    $HOME/.local/bin(N)
    $DOTFILES/bin(N)
    $HOME/.bun/bin(N)
    # Unversioned python and pip
    # https://discourse.brew.sh/t/pip-install-upgrade-pip-breaks-pip-when-installed-with-homebrew/5338
    $HOMEBREW_BASE/opt/python3/libexec/bin(N)
    $HOMEBREW_BASE/opt/sqlite3/bin(N)
    $HOME/.cargo/bin(N)
    $HOMEBREW_BASE/opt/ruby/bin(N)
    $HOMEBREW_BASE/{bin,sbin}(N)
    /usr/local/bin(N)
    $path
    # Keep LLVM last to avoid overriding Xcode's LLVM in projects that use it
    $HOMEBREW_BASE/opt/llvm/bin(N)
)

# Node
# ----------------------------------------------------------------------------
if [[ -e $HOME/.config/ssl/ca.pem ]]; then
    export NODE_EXTRA_CA_CERTS=$HOME/.config/ssl/ca.pem
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
pkg_config_path=($HOMEBREW_BASE/opt/{icu4c,openssl}/lib/pkgconfig(N))
export PKG_CONFIG_PATH=${(j|:|)pkg_config_path}

# Homebrew
# ----------------------------------------------------------------------------
# Use Bootsnap to speed up repeated brew calls
if [[ -d $HOMEBREW_BASE ]]; then
    export HOMEBREW_BOOTSNAP=1
fi

# Bun
if [[ -d $HOME/.bun/bin ]]; then
    export BUN_INSTALL="$HOME/.bun"
fi

# corepack
if (( $+commands[corepack] )); then
    export COREPACK_ENABLE_AUTO_PIN=0
fi

# ripgrep
if (( $+commands[rg] )); then
    export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep
fi

# Local config
# --------------------------------------------------------------------------
[[ -f $ZDOTDIR/local/zshenv ]] && source $ZDOTDIR/local/zshenv

# Remember the path so .zprofile can restore its order after path_helper
typeset -ga _zshenv_path=($path)
