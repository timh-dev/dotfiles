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
    stow -R "$package" 2>/dev/null || {
        echo "  Warning: failed to stow $package (may already exist)"
        continue
    }
done

echo "Done. Restart your terminal or run: source ~/.zshrc"
