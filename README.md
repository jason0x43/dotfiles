# Dotfiles

Dotfiles! Err...yay!

## Environment

I spend most of my time in the terminal.

Terminal: [wezterm](https://wezfurlong.org/wezterm/) Shell:
[fish](https://fishshell.com), Editor: [neovim](http://neovim.io)

## Paths

The location of my dotfiles is specified by the `DOTFILES` environment variable,
set to `~/.dotfiles` by default. Things that shouldn’t be in the repo, like
sensitive or host-specific information, go in `~/.local/config`.

Git doesn't support environment variable expansion in `include` statements in
`.gitconfig`, but it will automatically look in `~/.config/git/config`, and the
other tools I use can be pointed at `~/.config` as necessary.

Transient files, like vim sessions or zsh completions, are stored under
`XDG_CACHE_HOME`, set to `~/.cache` by default.

There’s a `bin/dotfiles` script that will put things in their expected places,
as well as installing some core homebrew packages and updating plugins.
