# Dotfiles

Dotfiles! Err...yay!

## Environment

I spend most of my time in the terminal.

Terminal: [wezterm](https://wezfurlong.org/wezterm/)
Shell: [zsh](http://zsh.sourceforge.net),
Editor: [neovim](http://neovim.io)

I use a number of vim plugins, managed by [lazy](https://github.com/folke/lazy.nvim).

## Paths

The location of my dotfiles is specified by the `DOTFILES` environment variable
in `.zshenv`. It’s set to `~/.dotfiles` by default. Things that shouldn’t be in
the repo, like sensitive or host-specific information, go in `~/.config`. The
local config directory isn’t configurable. Git doesn't support environment
variable expansion in `include` statements in `.gitconfig`, but it will
automatically look in `~/.config/git/config`, and the other tools I use can be
pointed at `~/.config` as necessary.

Transient files, like vim sessions or zsh completions, are stored under
`XDG_CACHE_HOME`, set to `~/.cache` by default.

There’s a `bin/dotfiles` script that will put things in their expected places,
as well as installing some core homebrew packages and updating plugins.

## Zsh and Git

Note that the zsh completion script that comes with git is outdated. The one
that comes with current distributions of zsh (including 5.x in macOS) is much
better. After installing or updating git via homebrew, remove
`/usr/local/share/zsh/site-functions/_git`.
