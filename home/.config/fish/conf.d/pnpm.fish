set -gx PNPM_HOME (set -q XDG_DATA_HOME; and echo $XDG_DATA_HOME; or echo ~/.local/share)/pnpm

if test -d $PNPM_HOME
    fish_add_path --move --path $PNPM_HOME/bin $PNPM_HOME
else
    set -e PNPM_HOME
end
