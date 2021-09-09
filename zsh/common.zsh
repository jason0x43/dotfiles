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

if [[ -d /home/linuxbrew ]]; then
    export HOMEBREW_BASE=/home/linuxbrew/.linuxbrew
elif [[ -d $HOME/.linuxbrew ]]; then
    export HOMEBREW_BASE=$HOME/.linuxbrew
else
    export HOMEBREW_BASE=/usr/local
fi

# This must be set for asdf-direnv to work properly. The _load_asdf_utils
# function in asdf-direnv's command.bash is unable to determine the proper
# value for ASDF_DIR automatically.
export ASDF_DIR=$HOMEBREW_BASE/opt/asdf/libexec
