function vi
    if command -q nvim
        if test -n "$WEZTERM_PANE"
            set -l socket /tmp/nvim-wt$WEZTERM_PANE
            rm -f $socket
            nvim --listen $socket $argv
        else
            nvim $argv
        end
    else if command -q vim
        vim $argv
    else
        command vi $argv
    end
end
