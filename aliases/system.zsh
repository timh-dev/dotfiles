# ============================================================================
# System & General Aliases
# ============================================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# List
alias ls='ls -G'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias lsd='ls -d */'

# Better tools (if installed)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -lah'
    alias la='eza -a'
    alias lt='eza --tree'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
    alias ccat='/bin/cat'
fi

# File operations
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'

# Grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Disk usage
alias df='df -h'
alias du='du -h'
alias dus='du -sh'

# Process
alias ps='ps aux'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias top='top -o cpu'
alias htop='htop'

# Network
alias ip='curl ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ports='lsof -i -P | grep LISTEN'
alias ping='ping -c 5'

# System
alias reload='exec zsh'
alias path='echo $PATH | tr ":" "\n"'
alias week='date +%V'
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Clipboard
alias pbcopy='pbcopy'
alias pbpaste='pbpaste'
alias copy='pbcopy'
alias paste='pbpaste'

# Quick edits
alias zshrc='vim ~/.zshrc'
alias vimrc='vim ~/.vimrc'
alias hosts='sudo vim /etc/hosts'

# Homebrew
alias brewup='brew update && brew upgrade && brew cleanup'
alias brewlist='brew list'
alias brewinfo='brew info'

# Make
alias m='make'
alias mi='make install'
alias mb='make build'
alias mt='make test'
alias mc='make clean'

# VSCode
alias code='code'
alias c='code .'

# Obsidian (if you want quick open)
alias obs='open -a Obsidian'

# ============================================================================
# System Functions
# ============================================================================

# Make directory and cd into it
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
function extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find file by name
function ff() {
    find . -type f -iname "*$1*"
}

# Find directory by name
function fd() {
    find . -type d -iname "*$1*"
}

# Search in files
function search() {
    grep -r "$1" .
}

# Get file size
function fs() {
    du -sh "$1"
}

# Create backup of file
function backup() {
    cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# Show disk usage of current directory
function diskusage() {
    du -sh * | sort -h
}

# Kill process by name
function killp() {
    ps aux | grep "$1" | grep -v grep | awk '{print $2}' | xargs kill -9
}

# Cheat sheet
function cheat() {
    curl "cheat.sh/$1"
}

# Generate random password
function genpass() {
    local length="${1:-20}"
    openssl rand -base64 "$length"
}

# Show system info
function sysinfo() {
    echo "System Information:"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime)"
    echo "Memory: $(free -h 2>/dev/null || vm_stat | grep 'Pages active' | awk '{print $3}')"
}
