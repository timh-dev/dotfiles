# Dotfiles

Dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## How Stow Works

Stow creates symlinks from this repo into your home directory. Each top-level folder is a "package" whose contents mirror `~/`.

For example, running `stow zsh` from this repo creates:

```
~/.zshrc  →  ~/dotfiles/zsh/.zshrc
```

That's it. Your `~/.zshrc` is just a symlink pointing back here, so any edits (either in `~/.zshrc` or `~/dotfiles/zsh/.zshrc`) are the same file.

## Setup

```bash
git clone https://github.com/timothypholmes/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Link dotfiles into ~
make link

# Install zsh plugins (required for .zshrc to load without errors)
make zsh

# Optionally install other packages (brew, npm, python, etc.)
make packages
```

## Commands

**Linking dotfiles** (stow):

```bash
make link       # Symlink all dotfiles into ~
make unlink     # Remove symlinks
make relink     # Remove and re-symlink (useful after changes)
make clean      # Clean up broken symlinks
```

**Installing packages** (separate from linking):

```bash
make brew       # Homebrew packages
make npm        # Global npm packages
make vscode     # VSCode extensions
make python     # Python tools (uv)
make vim        # Vim plugins
make zsh        # Zsh plugins (oh-my-zsh)
make qmenu      # Build qmenu TUI
make packages   # All of the above
```

## What Gets Linked

| Package    | Source in repo                     | Symlinked to                               |
|------------|------------------------------------|--------------------------------------------|
| `zsh`      | `zsh/.zshrc`                       | `~/.zshrc`                                 |
| `zsh`      | `zsh/.zprofile`                    | `~/.zprofile`                              |
| `git`      | `git/.config/git/config`           | `~/.config/git/config`                     |
| `vim`      | `vim/.vimrc`                       | `~/.vimrc`                                 |
| `tmux`     | `tmux/.tmux.conf`                  | `~/.tmux.conf`                             |
| `starship` | `starship/.config/starship.toml`   | `~/.config/starship.toml`                  |
| `vscode`   | `vscode/Library/Application Support/Code/User/...` | `~/Library/Application Support/Code/User/...` |
| `ghostty`  | `ghostty/Library/Application Support/...` | `~/Library/Application Support/...` |
| `welcome`  | `welcome/.config/welcome/welcome.conf` | `~/.config/welcome/welcome.conf`     |

## Not Linked (sourced or added to PATH)

These folders are **not** stow packages. They're referenced directly by `.zshrc`:

- `aliases/` - Shell aliases, sourced by `.zshrc`
- `functions/` - Shell functions, sourced by `.zshrc`
- `scripts/bin/` - Added to `$PATH` by `.zshrc`
- `packages/` - Package lists for `make brew`, `make npm`, etc.

## Welcome Screen

New shells open with a Great Lakes map drawn by `scripts/bin/welcome-art`. Color schemes, glyphs, pins and the load animation are set in `welcome/.config/welcome/welcome.conf`. Try a look before committing to it:

```bash
welcome-art --list                                    # schemes, glyphs, places, animations
welcome-art --scheme ice --animation ripple           # preview
WELCOME_NO_ANIMATION=1 zsh                            # skip the animation
```

## Adding a New Config

```bash
# 1. Create a package that mirrors your home directory
mkdir -p newtool/.config/newtool
mv ~/.config/newtool/config newtool/.config/newtool/config

# 2. Link it
cd ~/dotfiles
stow newtool
```
