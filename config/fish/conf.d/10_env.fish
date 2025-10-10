set -gx SHELL (which fish)
set -gx NODE_OPTIONS --disable-warning=ExperimentalWarning --enable-source-maps
set -gx EDITOR nvim
set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep
set -gx COREPACK_ENABLE_AUTO_PIN 0
set -gx FISH_AI_KEYMAP_2 ctrl-o
set -gx DOTNET_ROOT ~/.dotnet
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share
set -gx XDG_STATE_HOME ~/.local/state
set -gx GOPATH ~/Code/go
set -gx MANPAGER "sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"
