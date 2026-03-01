#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

if ! command -v stow &> /dev/null; then
    echo "GNU Stow not installed. Install it with: brew install stow"
    exit 1
fi

cd "$DOTFILES"

echo "Linking dotfiles..."

for package in */; do
    package=${package%/}
    [[ "$package" =~ ^(aliases|functions|packages|scripts|bin)$ ]] && continue

    echo "  Stowing $package"
    if ! stow -R "$package" 2>/dev/null; then
        echo "  Conflict in $package — adopting and restoring dotfiles version"
        stow --adopt "$package" 2>/dev/null && git restore "$package/" 2>/dev/null || {
            echo "  Warning: could not resolve conflict for $package"
            continue
        }
        stow -R "$package" 2>/dev/null
    fi
done

echo "Done. Restart your terminal or run: source ~/.zshrc"
