#!/bin/false
# shellcheck shell=bash
#
# Bash aliases

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
