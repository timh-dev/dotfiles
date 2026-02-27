#!/usr/bin/env zsh
# Run confetti after commands that take over 1 minute

preexec() {
    _cmd_start_time=$SECONDS
}

precmd() {
    if [[ -n $_cmd_start_time ]]; then
        local elapsed=$(( SECONDS - _cmd_start_time ))
        if (( elapsed > 60 )); then
            open raycast://confetti
        fi
        unset _cmd_start_time
    fi
}
