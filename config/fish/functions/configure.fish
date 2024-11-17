function configure
    if ! command -q fisher
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
            | source && fisher install jorgebucaran/fisher
    end

    if ! command -q tide
        fisher install IlanCosman/tide@v6
    end

    fisher update

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

    set -U fish_greeting ""
    set -U tide_git_icon 

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
