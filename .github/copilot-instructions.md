# Copilot Instructions for Dotfiles Repository

## Repository Overview

This is a personal dotfiles repository containing macOS and Linux shell
configurations, terminal setups, editor configs, and system automation scripts.
Primary technologies:

- **Fish** (main interactive shell)
- **Zsh** (shell scripts and functions)
- **Lua** (files for Neovim and Hammerspoon configs)
- **Python/Node/Swift** (utility scripts).

The repo targets macOS (primary) and Linux (Debian-based) environments.

**Main tools configured:** Kitty (terminal), Fish shell (interactive), Neovim
(editor), Hammerspoon/Phoenix (window management).

## Directory Structure

```
/
├── bin/              # 65 executable scripts (zsh, bash, python, node, swift)
│                     # Main: dotfiles (installer), checkhealth, git-* helpers
├── home/             # Mirror of ~ for managed files (names as they appear in ~)
│   ├── .bashrc, .zshenv, .editorconfig, .prettierrc, ...
│   └── .config/      # XDG-aware application configs
│       ├── nvim/     # Neovim config (Lua-based)
│       ├── fish/     # Fish shell (conf.d/ for autoloading)
│       ├── wezterm/  # WezTerm terminal emulator config
│       ├── hammerspoon/ # macOS automation (Lua)
│       ├── git/      # Git configuration
│       ├── bat/      # Syntax highlighting themes
│       ├── mise/     # Tool version manager
│       ├── yazi/     # File manager
│       └── zsh/      # Zsh configuration ($ZDOTDIR)
│           ├── .zshenv   # Environment and path (all shells)
│           ├── .zprofile # Restores path order after macOS path_helper
│           ├── .zshrc    # Interactive setup; sources conf.d/*.zsh
│           ├── conf.d/   # Options, completion, keys, aliases, tools, plugins
│           ├── functions/ # Autoloaded zsh functions
│           └── p10k.zsh  # Powerlevel10k prompt config
├── launchd/          # macOS launch agents (2 plist files)
├── nix-darwin/       # Nix Darwin system configuration
│   └── flake.nix     # Nix flake for system packages
├── terminal/         # Terminal themes and configs
└── powershell/       # PowerShell profile
```

**Key paths:**

- `~/.dotfiles` → Repository root (set by `$DOTFILES` env var)
- `~/<path>` → Symlinked to `home/<path>` for each file in `home/`
- `~/.local/config` → Host-specific configs (NOT in repo, never commit)
- `~/.cache` → Transient files (XDG_CACHE_HOME)

## Build & Validation Commands

### Managing Dotfiles

`bin/dotfiles` manages home directory files. Everything in `home/` mirrors its
location in `~` (e.g. `home/.config/fish/config.fish` →
`~/.config/fish/config.fish`). Each file is symlinked individually; directories
in `~` are real directories, so machine-specific files can live alongside
linked ones. Files that git ignores are never linked.

```bash
bin/dotfiles sync             # Link repo files into ~, remove stale links
bin/dotfiles sync -f          # Also replace local files in the way (backed up to ~/.local/state/dotfiles/backups)
bin/dotfiles status [dir...]  # Show link problems and untracked files; exits 1 if links need attention
bin/dotfiles import <path>... # Move files (or every file in a directory) from ~ into home/ and link them
bin/dotfiles forget <path>... # Move files from home/ back into ~
bin/dotfiles ignore <path>... # Hide local files from status (adds to ~/.config/dotfiles/ignore)
```

Ignore rules: generic patterns for the repo's own contents go in `.gitignore`
files. Machine-specific ignores go in `~/.config/dotfiles/ignore` (gitignore
syntax, relative to ~, never committed); the script copies them into
`.git/info/exclude`. Never add personal app names to the repo's `.gitignore`.

`sync`, `import`, and `forget` accept `-n/--dry-run`.

### Installing/Updating Tools

```bash
bin/dotfiles update [-i] [module...]
```

- `-i, --install` — Install missing dependencies (Homebrew, packages)
- `-l, --list` — List modules
- `<module>` — Run specific modules only (all run by default)

**Modules:** brew, uv, bat, fish, node, pnpm, bun, rust (macOS), launchd
(macOS), codex, claude, hammerspoon (macOS), apt (Linux)

**Initial setup on new machine:**

```bash
bin/dotfiles sync && bin/dotfiles update -i
```

### Syntax Validation

**Zsh scripts:**

```bash
zsh -n <script.zsh>   # Syntax check without execution
```

**Fish scripts:**

```bash
fish -n <script.fish>  # Syntax check
```

**Lua files (if stylua installed):**

```bash
stylua --check home/.config/nvim/  # Format check (uses home/.config/nvim/stylua.toml)
```

**Nix flake (if nix installed):**

```bash
cd nix-darwin && nix flake check
```

### Nix Darwin (macOS System Config)

**After changing `nix-darwin/flake.nix`:**

```bash
darwin-rebuild switch --flake nix-darwin#Jasons-MacBook-Pro
```

_Note: Requires Nix installed. Host name may differ - check flake.nix for
`darwinConfigurations` key._

## Core Dependencies

**Homebrew packages (installed by `bin/dotfiles update -i`):**

- bat, eza, fd, ripgrep, zoxide (modern CLI tools)
- mise (tool version manager)
- tig (terminal git UI)
- neovim (editor)
- 1password-cli (macOS only)

**Runtime requirements:**

- Zsh (shell for scripts in `bin/`)
- Fish (interactive shell)
- Git (for plugin management)
- curl (for downloading resources)

## Coding Conventions

### Shell Scripts

**Shebangs:**

- Zsh: `#!/usr/bin/env zsh` or `#!/bin/zsh`
- Bash: `#!/bin/bash` or `#!/usr/bin/env bash`
- Fish: Not used (files in `home/.config/fish/`)

**Error handling:**

- Bash scripts: Use `set -e` (exit on error) when appropriate
- Critical scripts use `set -euo pipefail` for strict mode
- Zsh scripts generally don't use strict mode (legacy compatibility)

**Indentation:**

- Shell/Fish/Lua: 2 spaces (see `home/.editorconfig`)
- Python: 4 spaces
- JS/TS: Tabs (width 2, see `home/.prettierrc`)

**Naming:**

- Executables: hyphen-separated verbs (`git-merge-pr`, `term_copy`)
- Functions: snake_case or camelCase (match existing style)

**File permissions:**

- All scripts in `bin/` must be executable (`chmod +x`)
- Check with: `stat -f "%A" <file>` (macOS) or `stat -c "%a" <file>` (Linux)

### Configuration Files

- **Lua** (Neovim/Hammerspoon): Follow `home/.config/nvim/stylua.toml` (80 char line,
  single quotes, 2 space indent)
- **Fish**: Autoload files in `home/.config/fish/conf.d/` (numeric prefix for order:
  `05_`, `10_`, `99_`)
- **Zsh**: Source order matters - `conf.d/` files load in name order, and the
  line editor plugins in `60-plugins.zsh` must load last

## Important Behavioral Notes

### Symlink Management

`bin/dotfiles sync`:

1. **Links** each file in `home/` (that git doesn't ignore) to the same path
   in `~`, creating directories as needed
2. **Replaces stale links** (broken, or pointing elsewhere in the repo), and
   replaces old whole-directory links with real directories, moving any
   untracked files from the linked directory into `~`
3. **Skips conflicts** (local files at a managed path) unless `--force`, which
   backs them up to `~/.local/state/dotfiles/backups/` first
4. **Removes links into the repo** that are broken or whose files were removed

To start managing a file, use `bin/dotfiles import ~/<path>` rather than
copying it into `home/` by hand (files added by hand are linked on the next
`sync`). New files created in `~` are local until imported.

### Environment Variable Loading

**Zsh load order:**

1. `home/.zshenv` → sets `ZDOTDIR` and sources `$ZDOTDIR/.zshenv` (XDG paths,
   DOTFILES, path, editor)
2. `$ZDOTDIR/.zprofile` (login shells) → restores the path order
3. `$ZDOTDIR/.zshrc` (interactive) → autoloads functions, loads the prompt,
   then sources `conf.d/*.zsh` in name order and `local/zshrc`

**Fish load order:**

1. `home/.config/fish/config.fish` (minimal)
2. Files in `home/.config/fish/conf.d/*.fish` (alphabetical, use numeric prefixes)

### Plugin Management

**Zsh plugins:**

- Managed by `zfetch` function (custom lightweight plugin manager)
- Located in `$ZPLUGDIR` (typically `~/.local/share/zsh/plugins`)

**Neovim plugins:**

- Managed by mini.deps
- These will be manually updated by the user from within neovim.

**Fish plugins:**

- Configured in `home/.config/fish/conf.d/` and updated via `bin/dotfiles update fish`

### Host-Specific Configuration

**Never commit to repo:**

- Secrets, API keys, tokens
- Machine-specific paths or settings

**Instead:**

- Store in `~/.local/config/` (automatically sourced by some tools)
- Document requirements in code comments
- Provide stub/example files if needed

## Validation Checklist

Before committing changes:

1. **Syntax check modified scripts:**
    - Zsh: `zsh -n <file>`
    - Fish: `fish -n <file>`
    - Lua: `stylua --check <file>` (if available)

2. **Test installation:**
    - Run `bin/dotfiles update <module>` for affected subsystem
    - Verify no errors in output

3. **Check file permissions:**
    - Executables in `bin/` must have mode 755 or 744
    - Config files should be 644

4. **Validate symlinks:**
    - Run `bin/dotfiles status` to check for broken or missing links
    - Verify configs load: open new shell, nvim, etc.

5. **Platform compatibility:**
    - macOS-specific: Check `[[ $OSTYPE == darwin* ]]` guards
    - Linux-specific: Check `[[ $OSTYPE == linux* ]]` guards

## Common Pitfalls & Workarounds

1. **Homebrew on Linux requires linuxbrew user:**
    - The installer creates this automatically
    - Commands run as: `sudo -u linuxbrew bash -c "cd && brew ..."`

2. **Fish configuration requires UV_VENV_CLEAR=1:**
    - Set when running `fish -c configure` (see `bin/dotfiles`)
    - Prevents Python virtual env conflicts

3. **Git completions conflict:**
    - Homebrew's `_git` completion conflicts with system version
    - `bin/dotfiles update brew` automatically removes it

## Files at Repository Root

```
.git/             # Git repository
.gitignore        # Ignores: plugins, sessions, compiled files, .vscode, .tool-versions
README.md         # User-facing documentation
bin/              # Executable scripts directory
home/             # Mirror of ~ for managed files (including .config/)
launchd/          # macOS launch agents
nix-darwin/       # Nix flake for system config
powershell/       # PowerShell profile
terminal/         # Terminal themes
```

## Trust These Instructions

The information above was validated by running commands and inspecting the
repository structure. When working in this repo, **trust these instructions
first** and only search/explore if:

- You encounter behavior that contradicts these instructions
- You need details about a specific file not covered here
- You're adding entirely new functionality not described here

For routine edits (modifying configs, updating scripts, fixing bugs), follow the
conventions and validation steps documented above without additional
exploration.
