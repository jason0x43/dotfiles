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
├── config/           # XDG-aware application configs
│   ├── nvim/         # Neovim config (Lua-based, lazy.nvim plugin manager)
│   ├── fish/         # Fish shell (65 functions, conf.d/ for autoloading)
│   ├── wezterm/      # WezTerm terminal emulator config
│   ├── hammerspoon/  # macOS window manager (Lua)
│   ├── git/          # Git configuration
│   ├── bat/          # Syntax highlighting themes
│   ├── mise/         # Tool version manager
│   └── yazi/         # File manager
├── home/             # Files symlinked to ~ (bashrc, editorconfig, prettierrc, zshenv)
├── zsh/              # Zsh configuration files
│   ├── .zshenv       # Environment setup (sourced first)
│   ├── .zshrc        # Interactive shell config
│   ├── functions/    # 32 autoloaded zsh functions
│   ├── alias.zsh     # Command aliases
│   └── p10k.zsh      # Powerlevel10k prompt config
├── launchd/          # macOS launch agents (2 plist files)
├── nix-darwin/       # Nix Darwin system configuration
│   └── flake.nix     # Nix flake for system packages
├── terminal/         # Terminal themes and configs
└── powershell/       # PowerShell profile
```

**Key paths:**

- `~/.dotfiles` → Repository root (set by `$DOTFILES` env var)
- `~/.config` → Symlinked from `config/` (XDG_CONFIG_HOME)
- `~/.local/config` → Host-specific configs (NOT in repo, never commit)
- `~/.cache` → Transient files (XDG_CACHE_HOME)

## Build & Validation Commands

### Primary Installation/Update Command

**Always run from repo root:**

```bash
bin/dotfiles [options] [group]
```

**Options:**

- `-i, --install` — Install missing dependencies (Homebrew, packages)
- `<group>` — Run specific group only (see groups below)

**Available groups:**

- `home` — Symlink dotfiles to ~/, fix terminfo (run first for new setup)
- `brew` — Install/update Homebrew packages
- `fish` — Update Fish plugins, run Fish configure
- `bat` — Rebuild bat cache for themes/syntax
- `zsh` — Update Zsh plugins, refresh completions
- `nvim` — Update Neovim plugins (Lazy), LSPs (Mason), treesitter parsers
- `rust` — Install/update Rust via rustup
- `node` — Update global npm packages
- `launchd` — Link and bootstrap launch agents (macOS only)
- `mas` — Upgrade Mac App Store apps (macOS only)

**Initial setup on new machine:**

```bash
bin/dotfiles -i       # Install everything from scratch
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
stylua --check config/nvim/  # Format check (uses config/nvim/stylua.toml)
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

**Homebrew packages (installed by `bin/dotfiles -i`):**

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
- Fish: Not used (files in `config/fish/`)

**Error handling:**

- Bash scripts: Use `set -e` (exit on error) when appropriate
- Critical scripts use `set -euo pipefail` for strict mode
- Zsh scripts generally don't use strict mode (legacy compatibility)

**Indentation:**

- Shell/Fish/Lua: 2 spaces (see `home/editorconfig`)
- Python: 4 spaces
- JS/TS: Tabs (width 2, see `home/prettierrc`)

**Naming:**

- Executables: hyphen-separated verbs (`git-merge-pr`, `term_copy`)
- Functions: snake_case or camelCase (match existing style)

**File permissions:**

- All scripts in `bin/` must be executable (`chmod +x`)
- Check with: `stat -f "%A" <file>` (macOS) or `stat -c "%a" <file>` (Linux)

### Configuration Files

- **Lua** (Neovim/Hammerspoon): Follow `config/nvim/stylua.toml` (80 char line,
  single quotes, 2 space indent)
- **Fish**: Autoload files in `config/fish/conf.d/` (numeric prefix for order:
  `05_`, `10_`, `99_`)
- **Zsh**: Source order matters - check `.zshrc` for plugin loading sequence

## Important Behavioral Notes

### Symlink Management

The `bin/dotfiles home` command:

1. **Creates symlinks** from `home/*` → `~/.{filename}`
2. **Creates symlinks** from `config/*` → `~/.config/{dirname}`
3. **Removes broken symlinks** in ~ and ~/.config
4. **Moves existing directories** to `~/.config.local/` to avoid conflicts

**Critical:** Never manually create files that conflict with symlinks. The
installer will move them!

### Environment Variable Loading

**Zsh load order:**

1. `home/zshenv` → sources `zsh/.zshenv`
2. `zsh/.zshenv` → sources `zsh/common.zsh` (sets XDG paths, DOTFILES, etc.)
3. `zsh/.zshrc` → loads plugins, sources config files

**Fish load order:**

1. `config/fish/config.fish` (minimal)
2. Files in `config/fish/conf.d/*.fish` (alphabetical, use numeric prefixes)

### Plugin Management

**Zsh plugins:**

- Managed by `zfetch` function (custom lightweight plugin manager)
- Located in `$ZPLUGDIR` (typically `~/.local/share/zsh/plugins`)
- Update with `bin/dotfiles zsh`

**Neovim plugins:**

- Managed by mini.deps
- These will be manually updated by the user from within neovim.

**Fish plugins:**

- Configured in `config/fish/conf.d/` and updated via `bin/dotfiles fish`

### Terminfo Fixes

The `bin/dotfiles home` command automatically:

- Installs WezTerm terminfo if missing
- Fixes backspace codes (C-h) for Neovim compatibility
- Uses `tic` and `infocmp` utilities

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
    - Run `bin/dotfiles <group>` for affected subsystem
    - Verify no errors in output

3. **Check file permissions:**
    - Executables in `bin/` must have mode 755 or 744
    - Config files should be 644

4. **Validate symlinks:**
    - After `bin/dotfiles home`, check `ls -la ~` for broken links
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
    - `bin/dotfiles brew` automatically removes it

4. **Terminfo must be fixed before Neovim will work properly:**
    - Run `bin/dotfiles home` first on new systems
    - Fixes C-h (backspace) keybinding issues

## Files at Repository Root

```
.git/             # Git repository
.gitignore        # Ignores: plugins, sessions, compiled files, .vscode, .tool-versions
README.md         # User-facing documentation
bin/              # Executable scripts directory
config/           # Application configurations directory
home/             # Files to symlink to ~/
launchd/          # macOS launch agents
nix-darwin/       # Nix flake for system config
powershell/       # PowerShell profile
terminal/         # Terminal themes
zsh/              # Zsh configuration
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
