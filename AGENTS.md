# Repository Guidelines

## Project Structure & Module Organization

This repo keeps macOS and shell tooling in dedicated folders so the
`bin/dotfiles` installer can symlink the right paths. Place executable helpers
in `bin/`—scripts should be idempotent and safe to rerun. Long-lived configs
live under `config/` for XDG-aware apps, while editor or shell-specific files
belong in `home/`, `zsh/`, `terminal/`, or `powershell/`. System automation such
as launch agents and Nix flake definitions sit in `launchd/` and `nix-darwin/`.
Keep host-specific files in `~/.local/config` as noted in the README, not in the
repository.

## Build, Test, and Development Commands

- `bin/dotfiles` — Syncs symlinks, installs core Homebrew formulas, and
  refreshes plugins; rerun after editing tracked configs.
- `bin/checkhealth` — Quick sanity check for required command-line tools on
  macOS or Linux.
- `darwin-rebuild switch --flake nix-darwin#Jasons-MacBook-Pro` — Applies the
  Nix Darwin system modules; run after changing `nix-darwin/flake.nix`. Run
  commands from the repo root so relative paths resolve correctly.

## Coding Style & Naming Conventions

Shell utilities generally target `zsh`; start files with the appropriate shebang
and enable strict mode (`set -euo pipefail`) when practical. Stick to two-space
indentation for shell, fish, and Lua scripts, and match the surrounding style in
legacy files. Name executables with hyphen-separated verbs (`git-merge-pr`,
`term_copy`). Dotfiles that mirror `$HOME` paths should follow the same relative
layout so `bin/dotfiles` remains predictable.

## Testing Guidelines

There is no dedicated automated test suite, so lean on fast linting: run
`zsh -n script.zsh` for syntax checks, `shellcheck` for POSIX-compatible helpers
when available, and `nix flake check nix-darwin` before committing Nix changes.
When altering launch agents or terminal configs, validate manually by reloading
the affected tool and record any platform-specific assumptions in your change
notes.

## Commit & Pull Request Guidelines

Write concise, imperative commit subjects modeled on `git log` (e.g., “Use
copilot-lsp and sidekick”). Group related edits into focused commits and explain
noteworthy side effects in the body. Pull requests should outline the
motivation, list manual validation steps, and reference issues or external
context when available; add screenshots for UI or terminal tweaks when visual
output changes.

## Security & Configuration Tips

Never commit secrets or machine-specific values—store them in `~/.local/config`
and document expectations instead. When adding new credentials or API
integrations, provide a stub example file and describe required environment
variables. Confirm file permissions (`chmod +x`) for scripts so installers and
launch agents remain executable.
