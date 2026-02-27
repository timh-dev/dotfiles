#!/usr/bin/env bash
# ============================================================================
# Install Script - Stow all dotfile packages
# ============================================================================

set -e

DOTFILES="$HOME/dotfiles"
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RESET="\033[0m"

log() { echo -e "${BLUE}==>${RESET} ${BOLD}$1${RESET}"; }
success() { echo -e "${GREEN}✓${RESET} $1"; }

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "❌ GNU Stow not installed. Run 'make bootstrap' first."
    exit 1
fi

cd "$DOTFILES"

log "Stowing dotfiles..."

# Stow all packages
for package in */; do
    package=${package%/}
    
    # Skip non-package directories
    [[ "$package" =~ ^(aliases|functions|packages|scripts|configs|bin)$ ]] && continue
    
    echo "📌 Stowing $package..."
    stow -R "$package" 2>/dev/null || {
        echo "⚠️  Failed to stow $package (may already exist)"
        continue
    }
    success "$package stowed"
done

echo ""
success "Dotfiles installed!"
echo ""
echo "💡 Next steps:"
echo "  1. Restart terminal or run: source ~/.zshrc"
echo "  2. Install packages: make packages"
echo ""
