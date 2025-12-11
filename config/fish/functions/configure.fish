function configure
    # Install plugin manager if it's missing
    if ! command -q fisher
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
            | source && fisher install jorgebucaran/fisher
    end

    set -l tide_installed 0
    if ! command -q tide
        set -l tide_installed 1
    end

    # Install/update plugins
    # @fish-lsp-disable 7001
    UV_VENV_CLEAR=1 fisher update >/dev/null

    # Disable `clear` in functions/tide/configure/choices/all/finish.fish
    set -l functions_path (dirname (status --current-filename))
    set -l tide_finish_config "$functions_path/tide/configure/choices/all/finish.fish"
    if test -f $tide_finish_config
        sed -i '' -E 's@^([[:space:]]*)(command -q clear && clear)@\1# \2@' $tide_finish_config
        functions -e finish
        source "$functions_path/tide/configure/choices/all/finish.fish"
    end

    tide configure \
        --auto \
        --style=Lean \
        --prompt_colors='16 colors' \
        --show_time='24-hour format' \
        --lean_prompt_height='Two lines' \
        --prompt_connection=Disconnected \
        --prompt_spacing=Compact \
        --icons='Many icons' \
        --transient=No

    # @fish-lsp-disable 2003
    set -U fish_greeting ""
    set -U tide_git_icon 
    set -U tide_dotnet_icon 
    set -U tide_dotnet_color blue
    set -U tide_dotnet_bg_color normal

    if ! contains mise $tide_right_prompt_items
        array_insert mise -2 tide_right_prompt_items
    end

    array_remove aws tide_right_prompt_items
    array_remove crystal tide_right_prompt_items
    array_remove direnv tide_right_prompt_items
    array_remove distrobox tide_right_prompt_items
    array_remove elixir tide_right_prompt_items
    array_remove gcloud tide_right_prompt_items
    array_remove go tide_right_prompt_items
    array_remove kubectl tide_right_prompt_items
    array_remove node tide_right_prompt_items
    array_remove os tide_left_prompt_items
    array_remove php tide_right_prompt_items
    array_remove python tide_right_prompt_items
    array_remove ruby tide_right_prompt_items
    array_remove terraform tide_right_prompt_items
    array_remove toolbox tide_right_prompt_items
    array_remove zig tide_right_prompt_items

    set -U tide_character_color green
    set -U tide_git_color_branch green
    set -U tide_pwd_color_dirs blue
    set -U tide_pwd_color_anchors blue
    set -U tide_character_vi_icon_visual V
    set -U tide_character_vi_icon_default :
    set -U tide_character_icon ➜

    set -e tide_pwd_icon
    set -e tide_pwd_icon_home
    set -e tide_pwd_icon_unwritable
end
