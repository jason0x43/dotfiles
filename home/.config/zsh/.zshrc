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
if [[ ! -x "$HOME/.local/bin/starship" ]]; then
    curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin -y
fi
eval "$(starship init zsh)"

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

# pnpm
# dummy entry for pnpm
# pnpm end
