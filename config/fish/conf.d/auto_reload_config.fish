function auto-reload --on-event fish_prompt -d 'auto source config.fish if gets modified!'
    set -l fish_config_file ~/.config/fish/config.fish
    if test -f $XDG_CONFIG_HOME/fish/config.fish
        set fish_config_file $XDG_CONFIG_HOME/fish/config.fish
    end

    set -l fish_config_time_new (date -r $fish_config_file +%s)
    if ! set -q FISH_CONFIG_TIME
        set -g FISH_CONFIG_TIME $fish_config_time_new
    else
        if test "$FISH_CONFIG_TIME" != "$fish_config_time_new"
            set FISH_CONFIG_TIME $fish_config_time_new
            source $fish_config_file
        end
    end
end

auto-reload
