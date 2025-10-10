function update_theme --on-variable theme
    if [ "$theme" = "light" ]
        fish_config theme choose 'Catppuccin Latte'
        set -gx LS_COLORS $(vivid generate catppuccin-latte)
    else
        fish_config theme choose 'Catppuccin Mocha'
        set -gx LS_COLORS $(vivid generate catppuccin-mocha)
    end
end
