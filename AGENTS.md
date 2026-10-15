# Agent notes

Personal dotfiles for macOS (primary) and Debian-based Linux. `README.md` explains the layout and `bin/dotfiles` (a Python script; run `bin/dotfiles -h` for its commands).

## Managed files

- `home/` mirrors `~`. `bin/dotfiles sync` symlinks each file individually, so directories in `~` are real and local files can sit next to linked ones. Editing a file under `home/` changes the live config.
- To start managing a file, run `bin/dotfiles import ~/<path>` instead of copying it into `home/`. `sync`, `import`, and `forget` accept `-n`/`--dry-run`; `bin/dotfiles status` reports link problems. The `pre-push` hook fails if `status` isn't clean.
- Repo `.gitignore` files are only for generic patterns about the repo's own contents. Machine-specific ignores go in `~/.config/dotfiles/ignore` (via `bin/dotfiles ignore <path>`); never add personal app names to the repo's `.gitignore`.
- Never commit secrets or machine-specific settings. Put them in local, ignored files next to the tool's config, e.g. `~/.config/git/local`, `~/.config/fish/conf.d/99_local_*.fish`, or `~/.config/zsh/local/zshrc`.
- `launchd/` holds macOS LaunchAgents installed by `bin/dotfiles update launchd`.

## Shell configs

- Zsh: `home/.zshenv` sets `ZDOTDIR=~/.config/zsh`. `.zshrc` sources `conf.d/*.zsh` in name order; `60-plugins.zsh` (line editor plugins) must stay last. Plugins are fetched with `zfetch $ZPLUGDIR <owner>/<repo>`.
- Fish: `conf.d/` files load alphabetically; use numeric prefixes (`05_`, `10_`, `99_`) to control order. Unprefixed files there come from tool installers and load after the numbered ones.
- Neovim plugins (`vim.pack`) are updated by the user from within Neovim; don't update them or `nvim-pack-lock.json`.

## Conventions

- Scripts in `bin/` must be executable. Guard platform-specific code (e.g. `[[ $OSTYPE == darwin* ]]`).
- Formatting follows `home/.editorconfig`, `home/.prettierrc`, and `home/.config/nvim/stylua.toml`.

## Validation

- Shell: `zsh -n <file>` or `fish -n <file>`.
- Lua: `stylua --check <path>`.
- Python (e.g. `bin/dotfiles`): `ruff check <file>`.
- When a change affects a subsystem, run `bin/dotfiles update <module>` (`bin/dotfiles update --list` shows the modules).
