# Plugins that hook into the line editor. These should be loaded last.

# zsh-syntax-highlighting
# --------------------------------------------------------------------------
# This should be loaded after everything else that defines widgets
# https://github.com/zsh-users/zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
zfetch $ZPLUGDIR zsh-users/zsh-syntax-highlighting
source $ZPLUGDIR/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

# zsh-history-substring-search
# --------------------------------------------------------------------------
# Load this after zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-history-substring-search
zfetch $ZPLUGDIR zsh-users/zsh-history-substring-search
source $ZPLUGDIR/zsh-users/zsh-history-substring-search/zsh-history-substring-search.zsh

# Color for found substrings
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=14,fg=0,bold'

# Color for not-found substrings
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=1,fg=0,bold'

# Default globbing flags
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'

# Make history keybindings search
bindkey -M vicmd "k" history-substring-search-up
bindkey -M vicmd "j" history-substring-search-down

# zsh-autosuggestions
# --------------------------------------------------------------------------
# Load this after zsh-syntax-highlighting and zsh-history-substring-search
# (https://github.com/tarruda/zsh-autosuggestions)
zfetch $ZPLUGDIR zsh-users/zsh-autosuggestions
source $ZPLUGDIR/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh

# Show suggestions in gray (bright black), matching fish
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Make autosuggest faster
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# Configure autosuggest to work properly with history substring search;
# without this, trying to history-substring-search with an empty line will
# hang zsh
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=("${(@)ZSH_AUTOSUGGEST_CLEAR_WIDGETS:#(up|down)-line-or-history}")
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)

# Key bindings
# --------------------------------------------------------------------------
# Match fish: ctrl-y accepts the suggestion, ctrl-e dismisses it, and
# ctrl-n/ctrl-p search history for the current input
bindkey -M viins '^y' autosuggest-accept
bindkey -M viins '^e' autosuggest-clear
bindkey -M viins '^n' history-substring-search-down
bindkey -M viins '^p' history-substring-search-up

# ctrl-e also cancels the completion menu, restoring what was typed
zmodload zsh/complist
bindkey -M menuselect '^e' undo

# Atuin
# --------------------------------------------------------------------------
if [[ ! -d "$HOME/.atuin" ]]; then
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive
fi
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
