#!/usr/bin/env bash

chroot='${debian_chroot:+($debian_chroot)}'
green='\[\033[01;32m\]'
blue='\[\033[01;34m\]'
nocolor='\[\033[00m\]'

if [ "$HOSTNAME" = "penguin" ]; then
    bracketed='@crostini'
else
    bracketed='\u@\h'
fi

PS1="${chroot}${green}[${bracketed}${nocolor}:${blue}\w${nocolor}${green}]\$${nocolor} "
