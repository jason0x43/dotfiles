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


Credits
-------

Much of the ZSH config was copied from [prezto](https://github.com/sorin-ionescu/prezto).
