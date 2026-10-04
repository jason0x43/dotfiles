#
# Defines environment variables before .zshrc is sourced
#
# This is the real content of ~/.zshenv. It exists here because ~/.zshenv is
# just use to set ZDOTDIR.
#
# This file should be kept light and fast. Anything that's slow or involves
# user interaction should go in zshrc.
#

# Core paths
# ----------------------------------------------------------------------------
export DOTFILES=${DOTFILES:-$HOME/.dotfiles}

export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-$TMPDIR}

export ZDATADIR=$XDG_DATA_HOME/zsh
export ZCACHEDIR=$XDG_CACHE_HOME/zsh

# Local config not checked into dotfiles
export ZLOCALDIR=$ZDOTDIR/local

export ZPLUGDIR=$ZDATADIR/plugins
export ZCOMPDIR=$ZCACHEDIR/completions

if [[ $OSTYPE == linux* ]]; then
    if [[ -d $HOME/.linuxbrew ]]; then
        export HOMEBREW_BASE=$HOME/.linuxbrew
    else
        export HOMEBREW_BASE=/home/linuxbrew/.linuxbrew
    fi
else
    if [[ -d /opt/homebrew ]]; then
        export HOMEBREW_BASE=/opt/homebrew
    else
        export HOMEBREW_BASE=/usr/local
    fi
fi

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
    $HOME/Library/pnpm/bin(N)
    $HOME/.deno/bin(N)
    $HOME/.dotnet/tools(N)
    $HOME/.dotnet(N)
    $HOME/.opencode/bin(N)
    # Unversioned python and pip
    # https://discourse.brew.sh/t/pip-install-upgrade-pip-breaks-pip-when-installed-with-homebrew/5338
    $HOMEBREW_BASE/opt/python3/libexec/bin(N)
    $HOMEBREW_BASE/opt/sqlite3/bin(N)
    $HOME/.cargo/bin(N)
    $HOMEBREW_BASE/opt/ruby/bin(N)
    $HOMEBREW_BASE/opt/php@8.1/bin(N)
    $HOMEBREW_BASE/{bin,sbin}(N)
    /usr/local/bin(N)
    $path
    # Keep LLVM last to avoid overriding Xcode's LLVM in projects that use it
    $HOMEBREW_BASE/opt/llvm/bin(N)
)

# Editors
# ----------------------------------------------------------------------------
if (( $+commands[nvim] )); then
    export SUDO_EDITOR=nvim
elif (( $+commands[vim] )); then
    export SUDO_EDITOR=vim
else
    export SUDO_EDITOR=vi
fi

export EDITOR=$SUDO_EDITOR
export VISUAL=$EDITOR

# Node
# ----------------------------------------------------------------------------
export NODE_OPTIONS='--disable-warning=ExperimentalWarning --enable-source-maps'

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
    export HOMEBREW_NO_ENV_HINTS=1
fi

# Bun
if [[ -d $HOME/.bun/bin ]]; then
    export BUN_INSTALL="$HOME/.bun"
fi

# corepack
if (( $+commands[corepack] )); then
    export COREPACK_ENABLE_AUTO_PIN=0
fi

# pnpm
if [[ -d $HOME/Library/pnpm ]]; then
    export PNPM_HOME=$HOME/Library/pnpm
fi

# .NET
if [[ -d $HOME/.dotnet ]]; then
    export DOTNET_ROOT=$HOME/.dotnet
fi

# ripgrep
if (( $+commands[rg] )); then
    export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep
fi

# Claude
export CLAUDE_CONFIG_DIR=$XDG_CONFIG_HOME/claude

# Local config
# --------------------------------------------------------------------------
[[ -f $ZDOTDIR/local/zshenv ]] && source $ZDOTDIR/local/zshenv

# Remember the path so .zprofile can restore its order after path_helper
typeset -ga _zshenv_path=($path)
