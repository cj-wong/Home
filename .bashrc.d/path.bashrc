# shellcheck shell=bash
#
# Path manipulation

if [ -d ~/.local/bin ]; then
    export PATH="$PATH:~/.local/bin"
fi
