# Agent notes

Personal dotfiles for macOS (primary) and Debian-based Linux. See `README.md`
for how the repo is laid out and how `bin/dotfiles` works.

## Managed files

- `home/` mirrors `~`; `bin/dotfiles sync` symlinks each file individually, so
  directories in `~` are real and local files can sit next to linked ones.
- To start managing a file, use `bin/dotfiles import ~/<path>` rather than
  copying it into `home/` by hand. `sync`, `import`, and `forget` take
  `-n`/`--dry-run`; `bin/dotfiles status` reports link problems.
- Repo `.gitignore` files are for generic patterns describing the repo's own
  contents. Machine-specific ignores go in `~/.config/dotfiles/ignore` (via
  `dotfiles ignore <path>`); never add personal app names to the repo's
  `.gitignore`.
- Never commit secrets or machine-specific settings. Put them next to the
  tool's config in `~` (e.g. `~/.config/git/local`,
  `~/.config/fish/conf.d/99_local_*.fish`) and ignore them.

## Shell configs

- Zsh: `home/.zshenv` sets `ZDOTDIR` to `~/.config/zsh`. `.zshrc` sources
  `conf.d/*.zsh` in name order, and the line editor plugins in
  `60-plugins.zsh` must load last. Plugins are fetched by the `zfetch`
  function into `$ZPLUGDIR`.
- Fish: `conf.d/` files load alphabetically; use numeric prefixes (`05_`,
  `10_`, `99_`) to control order.
- Neovim plugins (`vim.pack`) are updated by the user from within Neovim; don't
  update them or the lock file yourself.

## Conventions

- Scripts in `bin/` must be executable. Guard platform-specific code (e.g.
  `[[ $OSTYPE == darwin* ]]`).
- Formatting follows `home/.editorconfig`, `home/.prettierrc`, and
  `home/.config/nvim/stylua.toml`.

## Validation

- Syntax check changed shell files with `zsh -n <file>` or `fish -n <file>`.
- Check Lua with `stylua --check <path>`.
- Run `bin/dotfiles update <module>` for an affected subsystem when relevant
  (`bin/dotfiles update --list` shows the modules).
