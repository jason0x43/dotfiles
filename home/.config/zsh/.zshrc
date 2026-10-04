# Enable profiling
# zmodload zsh/zprof

# Functions
# ------------------------------------------------------------------------
# The fpath should be initialized before trying to load plugins (with zfetch)
# or trying to initialize completions
typeset -gU fpath
fpath=(
    $ZDOTDIR/functions
    $fpath
)

# Autoload all user shell functions, following symlinks
autoload -Uz $ZDOTDIR/functions/*(N-.:t)

# Prompt
# --------------------------------------------------------------------------
if [[ -f $ZDOTDIR/p10k.zsh ]]; then
    zfetch $ZPLUGDIR romkatv/powerlevel10k
    source $ZPLUGDIR/romkatv/powerlevel10k/powerlevel10k.zsh-theme
    source $ZDOTDIR/p10k.zsh
fi

# Config
# --------------------------------------------------------------------------
# Files are loaded in name order
for config in $ZDOTDIR/conf.d/*.zsh(N-.); do
    source $config
done
unset config

# Local config
# --------------------------------------------------------------------------
[[ -f $ZDOTDIR/local/zshrc ]] && source $ZDOTDIR/local/zshrc
