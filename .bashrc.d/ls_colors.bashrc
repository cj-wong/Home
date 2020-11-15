# shellcheck shell=bash
#
# Companion script for: https://github.com/trapd00r/LS_COLORS
# Sets dircolors for the terminal by using an external repo. Clones the repo
# if the files (repo) aren't locally found and given consent.

# Source lscolors.sh
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   any other integer: depends on source command
function lscolors::source() {
    . "${HOME}/.local/share/lscolors.sh"
}

# Install LS_COLORS and call lscolors::source.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   1: could not enter ~/LS_COLORS or return to previous dir
#   any other integer: depends on script and source command
function lscolors::install() {
    if ! pushd ~/LS_COLORS; then
        echo "Could not go into ~/LS_COLORS. Aborting." >&2
        return 1
    else
        bash install.sh && lscolors::source
    fi
    
    if ! popd; then
        echo "Could not return to previous directory"
        return 1
    fi
}

# Update the LS_COLORS local git repository and install new file
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if the origin was added successfully
#   1: if ~/LS_COLORS could not be traversed/entered
#   2: if popd would not work
#   3: if `git pull` failed - could mean not a git repo or something else
function lscolors::update() {
    echo "LS_COLORS update initiating..."
    if [ -d ~/LS_COLORS ]; then
        echo "LS_COLORS exists; trying to update its repository"
        if ! pushd ~/LS_COLORS; then
            echo "Could not go into ~/LS_COLORS. Aborting." >&2
            return 1
        fi
        if git pull > /dev/null; then
            bash install.sh && lscolors::source
        else
            echo "An error occurred; read the above message. Aborting." >&2
            return 3
        fi
        if ! popd; then
            echo "Could not return to original directory. Aborting." >&2
            return 2
        fi
    fi
}

# Module-level code

if [ -f "${HOME}/.local/share/lscolors.sh" ]; then
    lscolors::source
# If LS_COLORS wasn't installed, try installing it.
else
    # LS_COLORS depends on ~/.local/share existing.
    mkdir -p "${HOME}/.local/share"
    if [ -d ~/LS_COLORS ]; then
        read -r -p "LS_COLORS already exists. Do you want to delete it? [yN] " \
            prompt
        if [[ $prompt =~ ^[yY] ]]; then
            echo "Removing LS_COLORS."
            rm -rf ~/LS_COLORS
            git clone "git://github.com/trapd00r/LS_COLORS.git" ~/LS_COLORS \
                && lscolors::install
        else
            read -r -p "Reinstall using existing LS_COLORS? [yN] " reinstall
            if [[ $reinstall =~ ^[yY] ]]; then
                lscolors::install
            else
                echo "Aborting removal and ls_colors.bashrc." >&2
            fi
        fi
    fi
fi
