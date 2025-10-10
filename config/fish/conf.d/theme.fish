set -l theme_file ~/.local/share/theme

if test -f $theme_file
    set -l theme_value (cat $theme_file | string trim)
    
    if test "$theme_value" = "light"
        # fish_config theme choose "Catppuccin Latte"
        # set -gx LS_COLORS $(vivid generate catppuccin-latte)
    else
        # fish_config theme choose "Catppuccin Mocha"
        # set -gx LS_COLORS $(vivid generate catppuccin-mocha)
    end
else
    # fish_config theme choose "Catppuccin Mocha"
    # set -gx LS_COLORS $(vivid generate catppuccin-mocha)
end
