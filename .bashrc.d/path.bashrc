#!/bin/false
# shellcheck shell=bash
#
# Path manipulation

if [ -d ~/.local/bin ]; then
    PATH="$PATH:$HOME/.local/bin"
    export PATH
fi
