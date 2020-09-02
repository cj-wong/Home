#!/usr/bin/env bash
#
# Companion script for: https://github.com/trapd00r/LS_COLORS
# Sets dircolors for the terminal by using an external repo. Clones the repo
# if the files (repo) aren't locally found and given consent.

GIT_URL="git://github.com/trapd00r/LS_COLORS.git"
ALREADY_EXISTS="LS_COLORS already exists. Do you want to delete it? [yN] "

# If LS_COLORS wasn't installed, try installing it.
if [ -z "$lscolors_data_dir" ]; then
    # LS_COLORS depends on ~/.local/share existing.
    mkdir -p ~/.local/share
    if [ -d LS_COLORS ]; then
        read -p "$ALREADY_EXISTS" prompt
        if [[ $prompt =~ ^[yY] ]]; then
            echo "Removing LS_COLORS."
            rm -rf LS_COLORS
        else
            echo "Aborting removal and script."
            exit 1
        fi
    fi
    git clone "$GIT_URL" && cd LS_COLORS && bash install.sh
fi

file="$lscolors_data_dir/lscolors.sh"

if [ -f "$file" ]; then
    . "$file"
fi
