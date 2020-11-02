# shellcheck shell=bash
#
# Companion script for: https://github.com/trapd00r/LS_COLORS
# Sets dircolors for the terminal by using an external repo. Clones the repo
# if the files (repo) aren't locally found and given consent.

GIT_URL="git://github.com/trapd00r/LS_COLORS.git"
ALREADY_EXISTS="LS_COLORS already exists. Do you want to delete it? [yN] "
SHARE="$HOME/.local/share"
FILE="$SHARE/lscolors.sh"

# Update the LS_COLORS local git repository and install new file
# Arguments:
#   None
# Returns:
#   0: if the origin was added successfully
#   1: if ~/LS_COLORS could not be traversed/entered
#   2: if popd would not work
#   3: if `git pull` failed - could mean not a git repo or something else
function lsc_update() {
    echo "LS_COLORS update initiating..."
    if [ -d ~/LS_COLORS ]; then
        echo "LS_COLORS exists; trying to update its repository"
        pushd ~/LS_COLORS \
            || (echo "Could not go into ~/LS_COLORS. Aborting." && return 1)
        if git pull > /dev/null; then
            bash install.sh && . "$FILE"
        else
            echo "An error occurred; read the above message. Aborting."
            return 3
        fi
        popd \
            || (echo "Could not return to original directory. Aborting." \
                && return 2)
    fi
}

if [ -f "$FILE" ]; then
    . "$FILE"
# If LS_COLORS wasn't installed, try installing it.
else
    # LS_COLORS depends on ~/.local/share existing.
    mkdir -p "$SHARE"
    if [ -d ~/LS_COLORS ]; then
        read -r -p "$ALREADY_EXISTS" prompt
        if [[ $prompt =~ ^[yY] ]]; then
            echo "Removing LS_COLORS."
            rm -rf ~/LS_COLORS
            git clone "$GIT_URL" \
                && cd LS_COLORS \
                && bash install.sh \
                && . "$FILE"
        else
            read -r -p "Reinstall using existing LS_COLORS? [yN] " reinstall
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
