#!/usr/bin/env bash
#
# Set the prompt for bash.

chroot='${debian_chroot:+($debian_chroot)}'
green='\[\033[01;32m\]'
blue='\[\033[01;34m\]'
nocolor='\[\033[00m\]'

# Workaround for Anaconda's (mini)conda. Combines into $chroot var if present.
# Conda envs add to the beginning of the prompt, e.g. '(base) x$' where 'x$' is
# the original prompt.
conda_env=$(echo "$PS1" | cut -d' ' -f1 | egrep '^\(.+\)')
if [ ! -z "${conda_env}" ]; then
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
