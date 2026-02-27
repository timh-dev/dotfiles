# ============================================================================
# GitHub & Act (GitHub Actions) Aliases
# ============================================================================

# GitHub CLI
alias gh='gh'
alias ghpr='gh pr'
alias ghprc='gh pr create'
alias ghprv='gh pr view'
alias ghprl='gh pr list'
alias ghprm='gh pr merge'
alias ghprs='gh pr status'

alias ghissue='gh issue'
alias ghic='gh issue create'
alias ghiv='gh issue view'
alias ghil='gh issue list'

alias ghrepo='gh repo'
alias ghrc='gh repo create'
alias ghrv='gh repo view'
alias ghrcl='gh repo clone'

alias ghrun='gh run'
alias ghrl='gh run list'
alias ghrv='gh run view'
alias ghrw='gh run watch'

# Act (Local GitHub Actions)
alias act='act'
alias actl='act -l'
alias actpush='act push'
alias actpr='act pull_request'
alias actw='act workflow_dispatch'

# ============================================================================
# GitHub Functions
# ============================================================================

# Create PR with title and body
function ghprnew() {
    local title="$1"
    local body="${2:-}"
    if [[ -z "$title" ]]; then
        gh pr create --web
    else
        gh pr create --title "$title" --body "$body"
    fi
}

# View PR in browser
function ghprweb() {
    gh pr view --web
}

# Checkout PR locally
function ghprco() {
    local pr_number="$1"
    if [[ -z "$pr_number" ]]; then
        echo "Usage: ghprco <pr-number>"
        return 1
    fi
    gh pr checkout "$pr_number"
}

# Create issue
function ghinew() {
    local title="$1"
    local body="${2:-}"
    if [[ -z "$title" ]]; then
        gh issue create --web
    else
        gh issue create --title "$title" --body "$body"
    fi
}

# View issue in browser
function ghiweb() {
    local issue_number="$1"
    if [[ -z "$issue_number" ]]; then
        gh issue list
        return 1
    fi
    gh issue view "$issue_number" --web
}

# Clone repo
function ghclone() {
    gh repo clone "$1"
}

# View repo in browser
function ghweb() {
    gh repo view --web
}

# List workflows
function ghwl() {
    gh workflow list
}

# Run workflow
function ghwr() {
    local workflow="$1"
    if [[ -z "$workflow" ]]; then
        echo "Available workflows:"
        gh workflow list
        return 1
    fi
    gh workflow run "$workflow"
}

# View workflow runs
function ghwv() {
    gh run list --limit 10
}

# Watch latest run
function ghwatch() {
    gh run watch $(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
}

# ============================================================================
# Act Functions
# ============================================================================

# List all workflows
function actlist() {
    act -l
}

# Run specific workflow
function actrun() {
    local workflow="$1"
    if [[ -z "$workflow" ]]; then
        echo "Available workflows:"
        act -l
        return 1
    fi
    act -j "$workflow"
}

# Run workflow with secrets
function actsecret() {
    act --secret-file .env
}

# Dry run workflow
function actdry() {
    act -n
}

# Run with specific event
function actevent() {
    local event="$1"
    if [[ -z "$event" ]]; then
        echo "Usage: actevent <event>"
        echo "Events: push, pull_request, workflow_dispatch, etc."
        return 1
    fi
    act "$event"
}

# Run workflow with verbose output
function actv() {
    act -v
}

# Run specific job
function actjob() {
    local job="$1"
    if [[ -z "$job" ]]; then
        echo "Available jobs:"
        act -l
        return 1
    fi
    act -j "$job"
}

# ============================================================================
# GitHub Gist
# ============================================================================

alias ghgist='gh gist'
alias ghgc='gh gist create'
alias ghgl='gh gist list'
alias ghgv='gh gist view'

# Create gist from file
function ghgistf() {
    local file="$1"
    local desc="${2:-}"
    if [[ -z "$file" ]]; then
        echo "Usage: ghgistf <file> [description]"
        return 1
    fi
    gh gist create "$file" --desc "$desc"
}

# Create gist from clipboard
function ghgistc() {
    local desc="${1:-Clipboard content}"
    pbpaste | gh gist create --desc "$desc" -
}
