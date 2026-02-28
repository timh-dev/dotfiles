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

# Optionally install packages (brew, npm, python, etc.)
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
| `vscode`   | `vscode/.config/Code/User/...`     | `~/.config/Code/User/...`                  |
| `ghostty`  | `ghostty/Library/Application Support/...` | `~/Library/Application Support/...` |

## Not Linked (sourced or added to PATH)

These folders are **not** stow packages. They're referenced directly by `.zshrc`:

- `aliases/` - Shell aliases, sourced by `.zshrc`
- `functions/` - Shell functions, sourced by `.zshrc`
- `scripts/bin/` - Added to `$PATH` by `.zshrc`
- `packages/` - Package lists for `make brew`, `make npm`, etc.

## Adding a New Config

```bash
# 1. Create a package that mirrors your home directory
mkdir -p newtool/.config/newtool
mv ~/.config/newtool/config newtool/.config/newtool/config

# 2. Link it
cd ~/dotfiles
stow newtool
```
