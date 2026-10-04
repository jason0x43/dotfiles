# VI keybindings
# ------------------------------------------------------------------------
bindkey -v

# Get into vim command mode faster when hitting ESC
export KEYTIMEOUT=1

# History key bindings
# ------------------------------------------------------------------------
# Up and down arrow keys step through local history
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history
bindkey '^[[A' up-line-or-local-history
bindkey '^[[B' down-line-or-local-history

# Line editor
# ------------------------------------------------------------------------

# Let vi keys jump through the suggestion
bindkey '^f' vi-forward-word
bindkey '^b' vi-forward-blank-word
bindkey '^e' vi-end-of-line
