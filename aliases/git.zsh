# ============================================================================
# Git Aliases - Shell-specific shortcuts
# ============================================================================
# Note: Most git aliases are in ~/.config/git/config
# These are shell-specific wrappers and shortcuts

# Quick git command
alias g='git'

# Shell-specific shortcuts that need shell features
alias gs='git status'
alias gst='git status -sb'

# Commit shortcuts (keeping gcm for shell convenience)
alias gcm='git commit -m'
alias gcmain='git checkout main'
alias gcdevelop='git checkout develop'

# ============================================================================
# Git Functions
# ============================================================================

# Quick commit and push
function gcp() {
    local msg="${1:-Update}"
    git add -A
    git commit -m "$msg"
    git push
}

# Work in progress
function gwip() {
    git add -A
    git commit -m "WIP: $(date +%Y-%m-%d\ %H:%M:%S)"
}

# Undo WIP
function gunwip() {
    local commit_msg=$(git log -1 --pretty=%B)
    if [[ "$commit_msg" == WIP:* ]]; then
        git reset HEAD~1
        echo "✅ Unwipped"
    else
        echo "❌ Last commit is not a WIP"
    fi
}

# Current branch name
function gcurrent() {
    git branch --show-current
}

# Delete merged branches
function gcleanb() {
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | grep -v "develop" | xargs -n 1 git branch -d
    echo "✅ Cleaned merged branches"
}

# New branch from main
function gnew() {
    local branch_name="$1"
    if [[ -z "$branch_name" ]]; then
        echo "Usage: gnew <branch-name>"
        return 1
    fi
    git checkout main
    git pull
    git checkout -b "$branch_name"
}

# Sync with remote
function gsync() {
    local branch=$(gcurrent)
    git fetch origin
    git pull origin "$branch"
    echo "✅ Synced with origin/$branch"
}

# Show repo info
function ginfo() {
    echo "📂 Repository: $(basename $(git rev-parse --show-toplevel 2>/dev/null))"
    echo "🌿 Branch: $(gcurrent)"
    echo "📍 Remote: $(git remote get-url origin 2>/dev/null)"
    echo ""
    git status -sb
}

# Interactive rebase last N commits
function grebase() {
    local count="${1:-5}"
    git rebase -i HEAD~"$count"
}

# Fixup last commit
function gfix() {
    git add -A
    git commit --amend --no-edit
    echo "✅ Changes added to last commit"
}

# Clone and cd
function gcl() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Show what changed in last commit
function gshow() {
    git show --stat
}

# Search commits
function gsearch() {
    git log --all --grep="$1"
}

# Find who changed a line
function gblame() {
    git blame -w -C -C -C "$@"
}

# Squash last N commits into one
function gsquash() {
    local count="${1:-2}"
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "❌ Not a git repository"
        return 1
    fi
    
    # Get the first commit message
    local first_msg=$(git log --format=%B -n 1 HEAD~$((count-1)))
    
    echo "🔄 Squashing last $count commits..."
    echo "📝 Using message: $first_msg"
    
    # Create the rebase script
    GIT_SEQUENCE_EDITOR="sed -i '' -e '2,${count}s/^pick/squash/'" git rebase -i HEAD~$count
    
    if [ $? -eq 0 ]; then
        echo "✅ Squashed $count commits"
    else
        echo "❌ Squash failed - resolve conflicts and run: git rebase --continue"
    fi
}

# Push to origin with current branch
function gpo() {
    local branch=$(gcurrent)
    if [[ "$1" == "-f" ]] || [[ "$1" == "--force" ]]; then
        git push --force-with-lease origin "$branch"
    else
        git push origin "$branch"
    fi
}

alias gpof='gpo -f'
alias glp='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# List large files in git history
function glarge() {
    git rev-list --objects --all |
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
    sed -n 's/^blob //p' |
    sort --numeric-sort --key=2 |
    cut -c 1-12,41- |
    $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
}

# Lazy git - quick add, commit, push
function lazygit() {
    local msg="${*:-$(echo "Please enter commit message:" && read -r && echo "$REPLY")}"
    local branch=$(gcurrent)
    local force=false
    
    if [[ "$1" == "-f" ]] || [[ "$1" == "--force" ]]; then
        force=true
        shift
        msg="$*"
    fi
    
    echo "⏰ $(date)"
    git add .
    git commit -m "$msg"
    
    if [[ "$force" == "true" ]]; then
        git push --force-with-lease origin "$branch"
    else
        git push origin "$branch"
    fi
    
    echo "✅ $(date)"
}

alias lazygitf='lazygit -f'

# Pull latest from master into new branch
function gpullnew() {
    local current_branch=$(gcurrent)
    local new_branch="${current_branch}-new"
    
    git stash || { echo "❌ Failed to stash"; return 1; }
    git checkout master || git checkout main || { echo "❌ Failed to checkout master/main"; return 1; }
    git pull origin master || git pull origin main || { echo "❌ Failed to pull"; return 1; }
    git checkout -b "$new_branch" || { echo "❌ Failed to create $new_branch"; return 1; }
    git stash pop || { echo "❌ Failed to apply stash"; return 1; }
    
    echo "✅ Switched to new branch: $new_branch"
}
