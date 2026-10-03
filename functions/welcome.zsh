# ============================================================================
# Welcome Screen
# ============================================================================

function welcome() {
    local cyan='\033[0;36m'
    local blue='\033[0;34m'
    local green='\033[0;32m'
    local yellow='\033[0;33m'
    local magenta='\033[0;35m'
    local red='\033[0;31m'
    local white='\033[0;37m'
    local gray='\033[0;90m'
    local bright_blue='\033[1;34m'
    local bright_green='\033[1;32m'
    local bright_cyan='\033[1;36m'
    local bright_yellow='\033[1;33m'
    local bright_magenta='\033[1;35m'
    local reset='\033[0m'
    
    # Get time-based greeting
    local hour=$(date +"%H")
    local greeting
    if [ "$hour" -ge 5 ] && [ "$hour" -le 11 ]; then
        greeting="Good morning"
    elif [ "$hour" -ge 12 ] && [ "$hour" -le 17 ]; then
        greeting="Good afternoon"
    else
        greeting="Good evening"
    fi
    
    local cols=${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}
    cols=${cols:-100}
    
    # Great Lakes art; looks are set in ~/.config/welcome/welcome.conf.
    # Ctrl-C skips its animation without aborting shell startup.
    setopt localoptions localtraps
    trap '' INT
    echo ""
    welcome-art --width "$cols" --height "${LINES:-0}"

    echo ""
    
    # Build info line with optional git info
    local info_line=" ${cyan}※${reset} ${greeting}, ${blue}${USER}${reset} ${cyan}•${reset} ${magenta}$(uname -s) $(uname -m)${reset} ${cyan}•${reset} ${yellow}$(hostname)${reset}"
    
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current)
        local repo=$(basename $(git rev-parse --show-toplevel))
        info_line+=" ${cyan}•${reset} ${green}${repo}${reset} ${cyan}•${reset} ${green}${branch}${reset}"
    fi
    
    info_line+=" ${cyan}※${reset}"
    
    # Calculate visible length (without escape codes) and center
    local visible_length=$(echo -e "$info_line" | perl -pe 's/\033\[[0-9;]*m//g' | wc -m | tr -d ' ')
    local info_padding=$(( (cols - visible_length + 1) / 2 ))
    
    if [ $info_padding -gt 0 ]; then
        printf '%*s' $info_padding
    fi
    echo -e "$info_line"
    echo ""
    
    # Interactive menu
    menu
}
