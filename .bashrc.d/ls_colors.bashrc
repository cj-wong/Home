#!/usr/bin/env bash
#
# Companion script for: https://github.com/trapd00r/LS_COLORS
# Sets dircolors for the terminal by using an external repo. Clones the repo
# if the files (repo) aren't locally found and given consent.

GIT_URL="git://github.com/trapd00r/LS_COLORS.git"
ALREADY_EXISTS="LS_COLORS already exists. Do you want to delete it? [yN] "
SHARE="$HOME/.local/share"
FILE="$SHARE/lscolors.sh"

if [ -f "$FILE" ]; then
    . "$FILE"
# If LS_COLORS wasn't installed, try installing it.
else
    # LS_COLORS depends on ~/.local/share existing.
    mkdir -p "$SHARE"
    if [ -d LS_COLORS ]; then
        read -p "$ALREADY_EXISTS" prompt
        if [[ $prompt =~ ^[yY] ]]; then
            echo "Removing LS_COLORS."
            rm -rf LS_COLORS
            git clone "$GIT_URL" \
                && cd LS_COLORS \
                && bash install.sh \
                && . "$FILE"
        else
            read -p "Reinstall using existing LS_COLORS? [yN] " reinstall
            if [[ $reinstall =~ ^[yY] ]]; then
                cd LS_COLORS \
                    && bash install.sh \
                    && . "$FILE"
            else
                echo "Aborting removal and ls_colors.bashrc."
            fi
        fi
    fi
fi
