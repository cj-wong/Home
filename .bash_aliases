#!/usr/bin/env bash
#
# Bash aliases

# color output
alias ls='ls --color=auto'
alias grep='grep --color=auto'

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

# Gets line-by-line of running processes matching arguments.
# Globals:
#   None
# Arguments:
#   $@: args to be fed to grep
# Returns:
#   status code dependent on piped commands
function psgrep() {
    # shellcheck disable=SC2009
    # The use of "$@" twice is somewhat hacky but evidently re-colorizes output.
    ps aux | grep "$@" | grep -v grep | grep "$@"
}
