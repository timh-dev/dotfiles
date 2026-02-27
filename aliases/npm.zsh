# ============================================================================
# NPM & PNPM Aliases
# ============================================================================

# NPM shortcuts
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nu='npm uninstall'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'
alias ndev='npm run dev'
alias nlint='npm run lint'
alias nformat='npm run format'

# NPM info
alias nls='npm list --depth=0'
alias nlsg='npm list -g --depth=0'
alias nout='npm outdated'
alias nup='npm update'
alias nv='npm version'

# NPM scripts
alias nrs='npm run-script'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrd='npm run dev'

# PNPM shortcuts
alias pi='pnpm install'
alias pid='pnpm install --save-dev'
alias pig='pnpm install -g'
alias pu='pnpm uninstall'
alias pr='pnpm run'
alias ps='pnpm start'
alias pt='pnpm test'
alias pb='pnpm run build'
alias pdev='pnpm run dev'
alias plint='pnpm run lint'

# PNPM info
alias pls='pnpm list --depth=0'
alias plsg='pnpm list -g --depth=0'
alias pout='pnpm outdated'
alias pup='pnpm update'

# Yarn (if needed)
alias y='yarn'
alias yi='yarn install'
alias ya='yarn add'
alias yad='yarn add --dev'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'
alias yb='yarn build'

# Package.json
alias pkg='cat package.json'
alias pkgv='cat package.json | grep version'

# ============================================================================
# NPM/PNPM Functions
# ============================================================================

# Clean install
function nclean() {
    echo "🧹 Cleaning node_modules..."
    rm -rf node_modules package-lock.json
    npm install
    echo "✅ Done"
}

function pclean() {
    echo "🧹 Cleaning node_modules..."
    rm -rf node_modules pnpm-lock.yaml
    pnpm install
    echo "✅ Done"
}

# Quick init
function ninit() {
    npm init -y
    echo "✅ package.json created"
}

function pinit() {
    pnpm init
    echo "✅ package.json created"
}

# Run script with auto-detection
function run() {
    local script="$1"
    if [[ -f "pnpm-lock.yaml" ]]; then
        pnpm run "$script"
    elif [[ -f "yarn.lock" ]]; then
        yarn run "$script"
    else
        npm run "$script"
    fi
}

# Install with auto-detection
function install() {
    if [[ -f "pnpm-lock.yaml" ]]; then
        pnpm install "$@"
    elif [[ -f "yarn.lock" ]]; then
        yarn install "$@"
    else
        npm install "$@"
    fi
}

# Add package with auto-detection
function add() {
    if [[ -f "pnpm-lock.yaml" ]]; then
        pnpm add "$@"
    elif [[ -f "yarn.lock" ]]; then
        yarn add "$@"
    else
        npm install "$@"
    fi
}

# Show outdated packages
function ncheck() {
    if [[ -f "pnpm-lock.yaml" ]]; then
        pnpm outdated
    elif [[ -f "yarn.lock" ]]; then
        yarn outdated
    else
        npm outdated
    fi
}

# Update all packages
function nupall() {
    if [[ -f "pnpm-lock.yaml" ]]; then
        pnpm update --latest
    elif [[ -f "yarn.lock" ]]; then
        yarn upgrade
    else
        npm update
    fi
}

# List global packages
function nglobal() {
    if command -v pnpm >/dev/null 2>&1; then
        pnpm list -g --depth=0
    else
        npm list -g --depth=0
    fi
}

# Search npm registry
function nsearch() {
    npm search "$1"
}

# Show package info
function ninfo() {
    npm info "$1"
}

# Create new project
function ncreate() {
    local name="$1"
    local template="${2:-react}"
    
    case "$template" in
        react)
            npx create-react-app "$name"
            ;;
        next)
            npx create-next-app "$name"
            ;;
        vite)
            npm create vite@latest "$name"
            ;;
        *)
            echo "Unknown template: $template"
            echo "Available: react, next, vite"
            return 1
            ;;
    esac
}

# Run package without installing
function npx() {
    command npx "$@"
}

# PNPM equivalent
function pnpx() {
    pnpm dlx "$@"
}
