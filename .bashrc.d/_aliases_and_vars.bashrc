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

# shellcheck disable=SC2154
# Although not referenced, $debian_chroot may not be empty. This line is taken
# from the default .bashrc that ships with Debian and Ubuntu.
chroot="${debian_chroot:+($debian_chroot)}"
green='\[\033[01;32m\]'
blue='\[\033[01;34m\]'
nocolor='\[\033[00m\]'

# Workaround for Anaconda's (mini)conda. Combines into $chroot var if present.
# Conda envs add to the beginning of the prompt, e.g. '(base) x$' where 'x$' is
# the original prompt.
conda_env=$(echo "$PS1" \
    | cut --delimiter=' ' --fields=1 \
    | grep --extended-regexp '^\(.+\)')
if [ -n "${conda_env}" ]; then
    chroot="${conda_env} ${chroot}"
fi

# Workaround for ChromeOS Crostini. Suppresses default username (gmail address).
if [ "$HOSTNAME" = "penguin" ]; then
    user='@crostini'
else
    user='\u@\h'
fi

PS1="${chroot}${green}"
PS1+="[${user}${nocolor}:${blue}\w${nocolor}${green}]\$${nocolor} "

if [ -d ~/.local/bin ]; then
    if [[ $PATH != *"$HOME/.local/bin"* ]]; then
        # Only add to PATH if ~/.local/bin isn't already present.
        PATH="$PATH:$HOME/.local/bin"
        export PATH
    fi
fi
