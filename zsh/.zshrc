# ============================================================================
# ZSH Configuration
# ============================================================================

export ZSH_DISABLE_COMPFIX=true
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
    git docker npm python terraform
    zsh-autosuggestions zsh-z zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ============================================================================
# History
# ============================================================================
export HISTFILESIZE=1000000000
export HISTSIZE=1000000
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS

# ============================================================================
# PATH
# ============================================================================
export PATH="/opt/homebrew/bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/Documents/development/personal/dotfiles/scripts/bin:$PATH"

# ============================================================================
# Tools
# ============================================================================
eval "$(starship init zsh)"

# Lazy load thefuck
if command -v thefuck >/dev/null 2>&1; then
    fuck() {
        eval $(thefuck --alias)
        eval $(thefuck --alias f)
        unfunction fuck
        fuck "$@"
    }
    f() { fuck "$@"; }
fi

# Lazy load nvm
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    nvm() {
        unfunction nvm
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm "$@"
    }
    node() {
        unfunction node nvm
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        node "$@"
    }
    npm() {
        unfunction npm nvm
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        npm "$@"
    }
fi

if command -v uv >/dev/null 2>&1; then
    uv generate-shell-completion zsh 2>/dev/null | source /dev/stdin
fi

# ============================================================================
# Dotfiles
# ============================================================================
DOTFILES="$HOME/Documents/development/personal/dotfiles"

[ -d "$DOTFILES/aliases" ] && for f in "$DOTFILES"/aliases/*.zsh(N); do [ -r "$f" ] && source "$f"; done
[ -d "$DOTFILES/functions" ] && for f in "$DOTFILES"/functions/*.zsh(N); do [ -r "$f" ] && source "$f"; done

# ============================================================================
# Environment
# ============================================================================
export EDITOR="vim"
export VISUAL="vim"
export PYTHONDONTWRITEBYTECODE=1
export UV_PYTHON_PREFERENCE="only-managed"
export NODE_ENV="development"
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# ============================================================================
# Welcome Screen
# ============================================================================
if [[ -o interactive ]] && [[ -z "$DOTFILES_NO_WELCOME" ]]; then
    welcome
fi
