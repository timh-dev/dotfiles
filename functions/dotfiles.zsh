# ============================================================================
# Dotfiles Command - Simple file viewer
# ============================================================================

function dotfiles() {
    local file="${1:-git}"
    
    if [[ "$file" == "help" ]]; then
        echo "Available alias sheets:"
        for f in "$DOTFILES"/aliases/*.zsh; do
            echo "  df $(basename "$f" .zsh)"
        done
        return
    fi
    
    cat "$DOTFILES/aliases/${file}.zsh" 2>/dev/null || echo "File not found: $DOTFILES/aliases/${file}.zsh"
}

# Override df command with alias
alias df='dotfiles'
