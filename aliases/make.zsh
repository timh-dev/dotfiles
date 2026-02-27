# ============================================================================
# Make Aliases & Functions
# ============================================================================

# Make shortcuts
alias m='make'
alias mi='make install'
alias mb='make build'
alias mt='make test'
alias mc='make clean'
alias mr='make run'
alias md='make dev'
alias mh='make help'

# ============================================================================
# Make Functions
# ============================================================================

# List all make targets
function targets() {
    if [[ ! -f Makefile ]]; then
        echo "❌ No Makefile found"
        return 1
    fi
    
    echo "📋 Available Make targets:"
    make -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | sort -u | grep -v '^Makefile$'
}

# Run make with fzf selection (if fzf installed)
function mf() {
    if [[ ! -f Makefile ]]; then
        echo "❌ No Makefile found"
        return 1
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        echo "❌ fzf not installed. Install with: brew install fzf"
        return 1
    fi
    
    local target=$(make -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | sort -u | grep -v '^Makefile$' | fzf --height 40% --reverse --prompt="Make target: ")
    
    if [[ -n "$target" ]]; then
        echo "Running: make $target"
        make "$target"
    fi
}

# Show make target with description
function mtargets() {
    if [[ ! -f Makefile ]]; then
        echo "❌ No Makefile found"
        return 1
    fi
    
    echo "📋 Make targets with descriptions:"
    grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $1, $2}'
}

# Quick make help
alias mhelp='mtargets'
