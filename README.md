Dotfiles
========

Dotfiles! Err...yay!

Environment
-----------

I spend most of my time in [zsh](http://zsh.sourceforge.net), [tmux](http://tmux.sourceforge.net), and [iTerm2](http://iterm2.com), and [vim](http://www.vim.org) is my editor of choice. I use a number of vim plugins, managed by [vim-plug](https://github.com/junegunn/vim-plug), and a few tmux plugins, manged by [tpm](https://github.com/tmux-plugins/tpm).

Paths
----

The location of my dotfiles is specified by the `DOTFILES` environment variable in `.zshenv`. It’s set to `~/.dotfiles` by default. Things that shouldn’t be in the repo, like sensitive or host-specific information, go in `~/.config`. The local config directory isn’t configurable. Git doesn't support environment variable expansion in `include` statements in `.gitconfig`, but it will automatically look in `~/.config/git/config`, and the other tools I use can be pointed at `~/.config` as necessary.

Transient files, like vim sessions or zsh completions, are stored under `CACHEDIR`, set to `~/.cache` by default.

There’s an `init.sh` script that will put things in their expected places.

Theme
-----

Everything is themed with [Solarized](http://ethanschoonover.com/solarized), and my `.zshrc` configures iTerm2 with a Solarized palette using iTerm-specific escape sequences. (I was using iTerm profiles for a while, but I really hate it that switching profiles also resets my font size, which I sometimes change manually.) I’ve defined a couple of zsh functions to switch between the light and dark versions, not surprisingly called `light` and `dark`. Calling either of these functions will update the iTerm2 palette and store the current theme name in `$CACHEDIR/termbg`. When new shells are opened, or when vim is started, this file is checked and the theme is set accordingly.

I also have a CursorHold callback setup in vim so so that vim will check the termbg file when the user hasn’t typed for a while; that’s the easiest and least obtrusive way I’ve found to get Vim to update its theme given that there’s no real support for periodic tasks. There’s also a `Background` user command that will run the check immediately.

Credits
-------

Much of the ZSH config was copied from [prezto](https://github.com/sorin-ionescu/prezto).
