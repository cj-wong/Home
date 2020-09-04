#!/usr/bin/env bash
#
# Bash aliases

# color output
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ls
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# grep, for projects
alias xgrep="egrep --exclude-dir={.git,venv,__pycache__}"
alias pygrep="xgrep -r --include='*.py'"
alias mdgrep="xgrep -r --include='*.md'"
