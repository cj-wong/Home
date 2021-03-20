#!/bin/false
# shellcheck shell=bash
#
# Bash alias and environment variable manipulation.
# This module will be unconditionally sourced. It does not need to be enabled.

# Combine prefixes for the prompt variable.
#
# Globals:
#   debian_chroot
#   PS1
# Arguments:
#   None
# Outputs:
#   prefix: the prompt prefix with chroot and conda, if either are present
# Returns:
#   0: the prompt prefix was completed
function _vars::prompt::prefix() {
    local prefix
    local conda_env
    # shellcheck disable=SC2154
    # Although not referenced, $debian_chroot may not be empty.
    # This line is taken from the default .bashrc that ships with Debian
    # and Ubuntu.
    prefix="${debian_chroot:+($debian_chroot)}"

    # Workaround for Anaconda's (mini)conda.
    # This will prepend $prefix var if present.
    # Conda envs add to the beginning of the prompt,
    # e.g. '(base) x$' where 'x$' is the original prompt.
    conda_env=$(echo "$PS1" \
        | cut --delimiter=' ' --fields=1 \
        | grep --extended-regexp '^\(.+\)')
    if [ -n "${conda_env}" ]; then
        prefix="${conda_env} ${prefix}"
    fi

    echo "$prefix"
}

# Determine which user to use in the prompt variable.
#
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   user: the user string to use
# Returns:
#   0: user was determined
function _vars::prompt::user() {
    local user
    # Workaround for ChromeOS Crostini.
    # Suppresses default username (gmail address).
    if [ "$HOSTNAME" = "penguin" ]; then
        user='@crostini'
    else
        user='\u@\h'
    fi

    echo "$user"
}

# Module-level code

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

COLOR_GREEN='\[\033[01;32m\]'
COLOR_BLUE='\[\033[01;34m\]'
COLOR_DEF='\[\033[00m\]'

PS1="$(_vars::prompt::prefix)"
PS1+="${COLOR_GREEN}[$(_vars::prompt::user)${COLOR_DEF}:"
PS1+="${COLOR_BLUE}\w${COLOR_DEF}"
PS1+="${COLOR_GREEN}]\$${COLOR_DEF} "

if [ -d ~/.local/bin ]; then
    if [[ $PATH != *"$HOME/.local/bin"* ]]; then
        # Only add to PATH if ~/.local/bin isn't already present.
        PATH="$PATH:$HOME/.local/bin"
        export PATH
    fi
fi
