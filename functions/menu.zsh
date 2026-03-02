# ============================================================================
# Interactive Menu System
# ============================================================================

function menu() {
    local cyan='\033[0;36m'
    local yellow='\033[0;33m'
    local reset='\033[0m'
    
    local cols=${COLUMNS:-$(stty size 2>/dev/null | cut -d' ' -f2)}
    cols=${cols:-100}
    
    local title="${yellow}Quick Actions${reset}"
    local menu="   ${cyan}?${reset} help      ${cyan}p${reset} projects    ${cyan}c${reset} config    ${cyan}b${reset} bookmarks"
    
    # Calculate visible lengths and center
    local title_len=$(echo -e "$title" | perl -pe 's/\033\[[0-9;]*m//g' | wc -m | tr -d ' ')
    local menu_len=$(echo -e "$menu" | perl -pe 's/\033\[[0-9;]*m//g' | wc -m | tr -d ' ')
    
    local title_padding=$(( (cols - title_len + 1) / 2 ))
    local menu_padding=$(( (cols - menu_len + 1) / 2 ))
    
    if [ $title_padding -gt 0 ]; then
        printf '%*s' $title_padding
    fi
    echo -e "$title"
    
    if [ $menu_padding -gt 0 ]; then
        printf '%*s' $menu_padding
    fi
    echo -e "$menu"
    echo ""
}

# Help menu
function qhelp() {
    local qmenu_bin="$HOME/dotfiles/scripts/bin/qmenu"
    if [[ -x "$qmenu_bin" ]]; then
        "$qmenu_bin" help
    else
        echo "qmenu not built. Run: make qmenu"
    fi
}

# Projects browser
function qopen() {
    local qmenu_bin="$HOME/dotfiles/scripts/bin/qmenu"
    if [[ -x "$qmenu_bin" ]]; then
        "$qmenu_bin" projects
    else
        echo "qmenu not built. Run: make qmenu"
    fi
}

# Config editor
function qedit() {
    local qmenu_bin="$HOME/dotfiles/scripts/bin/qmenu"
    if [[ -x "$qmenu_bin" ]]; then
        "$qmenu_bin" config
    else
        echo "qmenu not built. Run: make qmenu"
    fi
}

# Bookmarks browser
function qbookmarks() {
    local qmenu_bin="$HOME/dotfiles/scripts/bin/qmenu"
    if [[ -x "$qmenu_bin" ]]; then
        "$qmenu_bin" bookmarks
    else
        echo "qmenu not built. Run: make qmenu"
    fi
}
