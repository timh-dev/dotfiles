# Dotfiles

Modern, modular dotfiles managed with GNU Stow.

## Philosophy

**Modular packages with XDG compliance:**
- Each tool gets its own package directory
- Mirrors your home directory structure
- Use `stow` to symlink packages
- XDG Base Directory compliant where possible

## Quick Start

**New Machine:**
```bash
# Clone and bootstrap everything
git clone https://github.com/timothypholmes/dotfiles.git ~/dotfiles
cd ~/dotfiles
make bootstrap
```

**Existing Setup:**
```bash
cd ~/dotfiles
make install      # Stow dotfiles
make packages     # Install all packages
```

## Structure

```
dotfiles/
├── git/                    # Git (XDG compliant)
│   └── .config/git/
├── zsh/                    # Zsh shell
│   ├── .zshrc
│   └── .zprofile
├── vim/                    # Vim editor
│   └── .vimrc
├── tmux/                   # Tmux multiplexer
│   └── .tmux.conf
├── starship/               # Starship prompt (XDG)
│   └── .config/starship.toml
├── vscode/                 # VSCode (XDG)
│   └── .config/Code/User/
├── ghostty/                # Ghostty terminal (macOS)
│   └── Library/Application Support/
├── aliases/                # Shell aliases (sourced by .zshrc)
│   ├── git.zsh
│   ├── docker.zsh
│   ├── python.zsh
│   ├── aws.zsh
│   └── ...
├── functions/              # Shell functions (sourced by .zshrc)
│   ├── welcome.zsh
│   ├── dotfiles.zsh
│   └── confetti.zsh
├── scripts/                # Executable scripts
│   └── bin/
├── packages/               # Package definitions
│   ├── Brewfile
│   ├── npm-global.txt
│   ├── vscode-extensions.txt
│   ├── python-tools.txt
│   ├── vim-plugins.txt
│   └── zsh-plugins.txt
└── configs/                # Reference configs (not stowed)
    ├── starship/
    └── vscode/
```

## Commands

```bash
# Setup
make bootstrap    # First-time setup (installs everything)
make install      # Stow all packages
make uninstall    # Unstow all packages
make restow       # Restow all packages

# Package Management
make brew         # Install Homebrew packages
make npm          # Install npm packages
make vscode       # Install VSCode extensions
make python       # Install Python tools (uv)
make vim          # Install Vim plugins
make zsh          # Install Zsh plugins
make packages     # Install all packages

# Utilities
make clean        # Remove broken symlinks
make help         # Show all commands
```

## Understanding Stow

**What is Stow?**

Stow is a symlink manager. It creates symbolic links from your dotfiles repo to your home directory, so you can:
- Keep all configs in one git repo
- Edit files in place (changes reflect in the repo)
- Selectively install configs per machine

**How Stow Works:**

1. **Package Structure** - Each directory is a "package" that mirrors `~`:
   ```
   git/
   └── .config/
       └── git/
           └── config    # This file will be linked
   ```

2. **Stow Command** - Creates symlinks from package → home:
   ```bash
   cd ~/dotfiles
   stow git
   ```

3. **Result** - Symlink created:
   ```
   ~/.config/git/config → ~/dotfiles/git/.config/git/config
   ```

**Key Concept:** Stow goes "up one level" from where you run it. If you're in `~/dotfiles` and run `stow git`, it symlinks `git/*` into `~/`.

## Stow Commands

```bash
# Install single package
stow git

# Install multiple packages
stow zsh vim tmux

# Install all packages
stow */

# Remove package
stow -D git

# Restow (useful after editing)
stow -R git

# Dry run (see what would happen)
stow -n git
```

## Adding New Configs

**Step 1:** Create package directory that mirrors your home structure
```bash
# If config lives at ~/.config/newtool/config
mkdir -p newtool/.config/newtool

# If config lives at ~/.newtoolrc
mkdir -p newtool
```

**Step 2:** Move existing config into package
```bash
# Move from home to package
mv ~/.config/newtool/config newtool/.config/newtool/config

# Or create new
echo "config" > newtool/.config/newtool/config
```

**Step 3:** Stow it
```bash
cd ~/dotfiles
stow newtool
```

**Step 4:** Verify symlink
```bash
ls -la ~/.config/newtool/config
# Should show: ~/.config/newtool/config -> ../../dotfiles/newtool/.config/newtool/config
```

## Multi-Machine Setup

**First Time Setup (New Machine):**
```bash
# 1. Clone repo
git clone https://github.com/timothypholmes/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install what you need
stow zsh git vim tmux  # Or: make install for everything

# 3. Install packages
make brew              # Install Homebrew packages
make packages          # Install all other packages
```

**Syncing Changes:**
```bash
# Machine 1: Make changes
cd ~/dotfiles
vim zsh/.zshrc         # Edit directly in repo
git add -A && git commit -m "Update zsh" && git push

# Machine 2: Pull changes
cd ~/dotfiles
git pull               # Changes automatically reflect (symlinks!)
```

**Why it works:** Since your configs are symlinked, editing `~/.zshrc` actually edits `~/dotfiles/zsh/.zshrc`. No copying needed!

## Aliases & Functions

All aliases and functions are in `aliases/` and `functions/` directories.
They're automatically sourced by `.zshrc`.

Aliases available:
- `aliases/git.zsh` - Git shortcuts
- `aliases/github.zsh` - GitHub CLI
- `aliases/docker.zsh` - Docker commands
- `aliases/python.zsh` - Python/UV tools
- `aliases/aws.zsh` - AWS CLI shortcuts
- `aliases/terraform.zsh` - Terraform commands
- `aliases/npm.zsh` - npm shortcuts
- `aliases/make.zsh` - Make shortcuts
- `aliases/system.zsh` - System utilities
- `aliases/weather.zsh` - Weather commands

Functions available:
- `functions/welcome.zsh` - Welcome screen with ASCII art
- `functions/dotfiles.zsh` - Dotfiles help system (df command)
- `functions/confetti.zsh` - Celebration animations

Use `df help` to see all available aliases organized by category.

## Package Management

All packages are defined in `packages/` directory:

```bash
packages/
├── Brewfile              # Homebrew packages & casks
├── npm-global.txt        # Global npm packages
├── vscode-extensions.txt # VSCode extensions
├── python-tools.txt      # Python tools (uv)
├── vim-plugins.txt       # Vim plugins (vim-plug)
└── zsh-plugins.txt       # Zsh plugins (Oh My Zsh)
```

**Install packages:**
```bash
# Individual
make brew
make npm
make vscode
make python
make vim
make zsh

# All at once
make packages
```

**Add new packages:**
```bash
# Edit the appropriate file
vim packages/Brewfile
vim packages/npm-global.txt
vim packages/vscode-extensions.txt
vim packages/python-tools.txt
vim packages/vim-plugins.txt
vim packages/zsh-plugins.txt

# Install
make brew        # or make npm, make vscode, etc.
```

## Tools Configured

- Shell: Zsh + Oh My Zsh + Starship prompt
- Editor: Vim + VSCode
- Terminal: Ghostty
- Version Control: Git + GitHub CLI
- Languages: Python (uv), Node.js (npm)
- Infrastructure: Terraform, Docker, AWS CLI
- Utilities: tmux, bat, eza, fzf

---

**Modular. Portable. Stow-powered.**
