# Some core variables are set here so that they can be loaded by scripts like
# base16_theme that may be run in a non-standard environment.

export DOTFILES=$HOME/.dotfiles

export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-$TMPDIR}

export ZDATADIR=$XDG_DATA_HOME/zsh
export ZCONFDIR=$XDG_CONFIG_HOME/local/zsh
export ZCACHEDIR=$XDG_CACHE_HOME/zsh

export ZPLUGDIR=$ZDATADIR/plugins
export ZFUNCDIR=$ZDATADIR/functions
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
