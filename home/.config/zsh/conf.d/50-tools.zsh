# Less
# ----------------------------------------------------------------------------
export LESS='-F -g -i -M -R -w -X -z-4'
export PAGER='less'

# bat
# ------------------------------------------------------------------------
if (( $+commands[bat] )); then
    # BAT_THEME is also used by delta, so set it here rather than in the bat
    # config file
    export BAT_THEME=wezterm

    # Render man pages with bat, stripping the formatting man adds
    export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"
fi

# fzf
# ------------------------------------------------------------------------
export FZF_DEFAULT_OPTS='--color=bg+:0,fg+:15,prompt:4,hl:5,hl+:5 --prompt=➜\ '

# mise
# ------------------------------------------------------------------------
if (( $+commands[mise] )); then
    eval "$(mise activate zsh)"
fi

# Bun
# --------------------------------------------------------------------------
if [[ -s "$HOME/.bun/_bun" ]]; then
    source "$HOME/.bun/_bun"
fi

# 1Password
# --------------------------------------------------------------------------
if [[ -f $HOME/.config/op/plugins.sh ]]; then
    . $HOME/.config/op/plugins.sh
fi

# Google Cloud
# --------------------------------------------------------------------------
if [[ -d $HOMEBREW_BASE/share/google-cloud-sdk ]]; then
    . $HOMEBREW_BASE/share/google-cloud-sdk/path.zsh.inc
    . $HOMEBREW_BASE/share/google-cloud-sdk/completion.zsh.inc
fi

# zoxide
# --------------------------------------------------------------------------
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh --cmd cd)"
fi

# Terminal
# --------------------------------------------------------------------------
# 4-space tabs
[[ -t 1 ]] && tabs -4
