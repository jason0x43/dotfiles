# Generated completions
# ------------------------------------------------------------------------
# Completion files that are generated or copied from installed tools. They
# live in a cache directory ahead of the user completions directory, so
# stale local copies don't shadow them.

status is-interactive; or return

set -g __fish_gencomp_dir (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo ~/.cache)/fish/tool_completions
set -p fish_complete_path $__fish_gencomp_dir

# Some tools are added to PATH by conf.d files that load after this one, so
# generate completions just before the first prompt
function __fish_gencomp --on-event fish_prompt
    functions -e __fish_gencomp
    mkdir -p $__fish_gencomp_dir

    # Usage: __fish_gencomp_generate <name> <command...>
    # Writes the output of <command> to <name>.fish when that file is missing
    # or more than a day old.
    function __fish_gencomp_generate
        set -l dest $__fish_gencomp_dir/$argv[1].fish
        if test -f $dest; and test (path mtime --relative $dest) -lt 86400
            return
        end

        if not $argv[2..] >$dest.tmp 2>/dev/null; or not test -s $dest.tmp
            rm -f $dest.tmp
            return
        end

        if cmp -s $dest.tmp $dest
            # Unchanged; reset the clock
            rm -f $dest.tmp
            touch $dest
        else
            mv -f $dest.tmp $dest
        end
    end

    command -q dotfiles; and __fish_gencomp_generate dotfiles dotfiles completion fish
    command -q wt; and __fish_gencomp_generate wt wt completions fish

    # pnpm's script also completes pn, but fish only loads it for pnpm
    if command -q pnpm
        __fish_gencomp_generate pnpm pnpm completion fish
        ln -sf pnpm.fish $__fish_gencomp_dir/pn.fish
    end

    # Docker Desktop ships fish completions; copy them when they're new or
    # updated
    for f in /Applications/Docker.app/Contents/Resources/etc/*.fish-completion
        set -l dest $__fish_gencomp_dir/(path basename -E $f).fish
        if not test -f $dest; or test $f -nt $dest
            cp $f $dest
        end
    end

    functions -e __fish_gencomp_generate
end
