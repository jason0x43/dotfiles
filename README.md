# Dotfiles

Dotfiles! Err...yay!

## Environment

I spend most of my time in the terminal.

Terminal: [wezterm](https://wezfurlong.org/wezterm/) Shell:
[fish](https://fishshell.com), Editor: [neovim](http://neovim.io)

## Paths

The location of my dotfiles is specified by the `DOTFILES` environment variable,
set to `~/.dotfiles` by default. Things that shouldn’t be in the repo, like
sensitive or host-specific information, live alongside the managed files in
`~/.config` (for example `~/.config/git/local` or
`~/.config/fish/conf.d/99_local_*.fish`). Add them to `dotfiles ignore` so
`dotfiles status` hides them and `dotfiles import` and git skip them.

Git doesn't support environment variable expansion in `include` statements in
`.gitconfig`, but it will automatically look in `~/.config/git/config`, and the
other tools I use can be pointed at `~/.config` as necessary.

Transient files, like vim sessions or zsh completions, are stored under
`XDG_CACHE_HOME`, set to `~/.cache` by default.

## Managing dotfiles

Files managed by the repo live in `home/`, named and arranged exactly as they
are in `~` (so `~/.config/fish/config.fish` lives at
`home/.config/fish/config.fish`). Each file is symlinked individually, and
directories in `~` are always real directories, so files that are specific to
one machine can live right next to linked ones. Anything that isn't in the
repo is local.

The `bin/dotfiles` script manages the links:

- `dotfiles sync` — link every file in `home/` (except files git ignores) into
  `~`, replace stale links, and remove links to files that were removed from
  the repo. Local files that are in the way are left alone unless `--force` is
  given, in which case they're backed up to `~/.local/state/dotfiles/backups`
  first.
- `dotfiles import <path>...` — move files from `~` into `home/` and replace
  them with links. Importing a directory imports every file in it.
- `dotfiles forget <path>...` — the reverse of `import`
- `dotfiles status [dir...]` — show links that need attention, and untracked
  files in `~` that aren't in the repo. By default it checks everything under
  the top-level directories in `home/` (e.g. `~/.config`), only descending into
  directories that also exist in the repo.

`sync`, `import`, and `forget` take `-n`/`--dry-run`.

A `pre-push` hook in `.githooks/` fails the push if `dotfiles status` isn't
clean. Enable it in a clone with `git config core.hooksPath .githooks`.

- `dotfiles ignore <path>...` — hide local files from `status`

Files that git ignores are never linked or listed as untracked. There are two
places for ignore rules:

- `.gitignore` files in the repo, for generic patterns that describe the repo's
  own contents (e.g. `fish_variables` in `home/.config/fish/.gitignore`)
- `~/.config/dotfiles/ignore`, for the local files on a particular machine
  (e.g. apps you don't manage). It uses gitignore syntax with paths relative to
  `~`, and isn't part of the repo, so the list stays private. `dotfiles ignore`
  adds rules to it, or it can be edited directly. Its rules are copied into the
  repo's `.git/info/exclude`, so git won't add those files either.

Some apps save files by replacing them, which turns a link back into a regular
file. `status` reports these as conflicts; `dotfiles import -f <path>` keeps the
local version, and `dotfiles sync -f` keeps the repo's.

`dotfiles update [-i] [module...]` installs core homebrew packages and updates
tools and plugins (`dotfiles update --list` shows the modules). On a new
machine, run `dotfiles sync && dotfiles update -i`.
