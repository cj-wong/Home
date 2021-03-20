#!/bin/false
# shellcheck shell=bash
#
# Bash alias and environment variable manipulation.
# This module will be unconditionally sourced. It does not need to be enabled.

# Aliases

# color output
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# human-readable units
alias df='df -h'
alias du='du -h'

# ls
alias lh='ls -h'
alias ll='lh -alF'
alias la='lh -A'
alias l='ls -CF'

# grep
alias fgrep='grep -F'
alias egrep='grep -E'

# grep, special cases
alias psgrep=psgrep
alias xgrep="egrep --exclude-dir={.git,venv,__pycache__}"
alias mdgrep="xgrep -r --include='*.md'"
alias pygrep="xgrep -r --include='*.py'"
alias shgrep="xgrep -r --include='*.sh' --include='*.bashrc'"

# Environment variables

if [ -d ~/.local/bin ]; then
    if [[ $PATH != *"$HOME/.local/bin"* ]]; then
        # Only add to PATH if ~/.local/bin isn't already present.
        PATH="$PATH:$HOME/.local/bin"
        export PATH
    fi
fi
