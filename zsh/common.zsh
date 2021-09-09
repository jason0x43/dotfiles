# Some core variables are set here so that they can be loaded by scripts like
# base16_theme that may be run in a non-standard environment.

export DOTFILES=$HOME/.dotfiles
export CACHEDIR=$HOME/.cache
export CONFIGDIR=$HOME/.config
export DATADIR=$HOME/.local/share

export ZCACHEDIR=$CACHEDIR/zsh
export ZDATADIR=$DATADIR/zsh
export ZPLUGDIR=$ZCACHEDIR/plugins
export ZCOMPDIR=$ZCACHEDIR/completions
export ZFUNCDIR=$ZDATADIR/functions

export ASDF_DATA_DIR=$DATADIR/asdf

if [[ -d /home/linuxbrew ]]; then
    export HOMEBREW_BASE=/home/linuxbrew/.linuxbrew
elif [[ -d $HOME/.linuxbrew ]]; then
    export HOMEBREW_BASE=$HOME/.linuxbrew
else
    export HOMEBREW_BASE=/usr/local
fi
