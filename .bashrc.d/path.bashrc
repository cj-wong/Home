#!/bin/false
# shellcheck shell=bash
#
# Path manipulation

if [ -d ~/.local/bin ]; then
    if [[ $PATH != *"$HOME/.local/bin"* ]]; then
        # Only add to PATH if ~/.local/bin isn't already present.
        PATH="$PATH:$HOME/.local/bin"
        export PATH
    fi
fi
