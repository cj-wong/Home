# shellcheck shell=bash
#
# Companion script for: https://github.com/trapd00r/LS_COLORS
# Sets dircolors for the terminal by using an external repo. Clones the repo
# if the files (repo) aren't locally found and given consent.

# Source lscolors.sh.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the file could be successfully sourced
function lscolors::source() {
    . "${HOME}/.local/share/lscolors.sh"
}

# Download LS_COLORS anew. May fail if $LSC_REPO_HOME already exists.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the git clone succeeded
function lscolors::download() {
    echo "Downloading newest LS_COLORS into ${LSC_REPO_HOME}."
    git clone "git://github.com/trapd00r/LS_COLORS.git" "$LSC_REPO_HOME"
}

# Install LS_COLORS and call lscolors::source.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the install succeeded
#   1: "$LSC_REPO_HOME" could not be traversed via pushd
#   2: the install succeeded, but could not return to previous directory
#      via popd
function lscolors::install() {
    echo "Beginning installation."
    if ! pushd "$LSC_REPO_HOME"; then
        echo "Error: Could not go into ${LSC_REPO_HOME}." >&2
        return 1
    else
        bash install.sh && lscolors::source
        echo "Installation was successful."
    fi
    
    if ! popd; then
        echo "Error: Could not return to previous directory." >&2
        return 2
    fi
}

# Ask to reinstall LS_COLORS, and reinstall if accepted.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: reinstall was accepted and succeeded
#   1: reinstall was aborted
function lscolors::reinstall() {
    local answer
    read -r -p "Reinstall using existing LS_COLORS? [yN] " answer
    if [[ $answer =~ ^[yY] ]]; then
        echo "Reinstalling..."
        lscolors::install
    else
        echo "Reinstall has been aborted." >&2
        return 1
    fi
}

# Update the LS_COLORS local git repository and install new file
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the install and update succeeded
#   1: "$LSC_REPO_HOME" could not be traversed via pushd
#   2: could not return to previous directory via popd
#   3: could not update via git-pull (may not be a git repo)
#   4: the directory (git repo) does not exist
function lscolors::update() {
    echo "LS_COLORS update initiating..."
    if [ -d "$LSC_REPO_HOME" ]; then
        echo "LS_COLORS exists; trying to update its repository"
        if ! pushd "$LSC_REPO_HOME"; then
            echo "Error: Could not go into ${LSC_REPO_HOME}." >&2
            return 1
        fi
        if git pull > /dev/null; then
            bash install.sh && lscolors::source
            echo "Successfully updated LS_COLORS."
            return 0
        else
            echo "Error: Update failed. Read the message above for details." >&2
            return 3
        fi
        if ! popd; then
            echo "Error: Could not return to original directory." >&2
            return 2
        fi
    else
        echo "Error: LS_COLORS doesn't exist." >&2
        return 4
    fi
}

# Ask to remove existing LS_COLORS directory, and delete if accepted.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the deletion was successful
#   1: deletion was aborted
function lscolors::delete() {
    local answer

    echo "${LSC_REPO_HOME} already exists."
    read -r -p "Do you want to delete it? [yN] " answer
    if [[ ! $answer =~ ^[yY] ]]; then
        echo "Deletion has been aborted." >&2
        return 1
    fi

    unset answer

    echo "Are you sure you really want to delete ${LSC_REPO_HOME}?"
    read -r -p "[yN] " answer
    if [[ $answer =~ ^[yY] ]]; then
        echo "Removing ${LSC_REPO_HOME}."
        rm --recursive --force "$LSC_REPO_HOME"
    else
        echo "Deletion has been aborted." >&2
        return 1
    fi
}

# Module-level code

LSC_REPO_HOME="${HOME}/LS_COLORS"

if [ -f "${HOME}/.local/share/lscolors.sh" ]; then
    lscolors::source
# If LS_COLORS wasn't installed, try installing it.
else
    # LS_COLORS depends on ~/.local/share existing.
    mkdir --parents "${HOME}/.local/share"
    if [ -d "$LSC_REPO_HOME" ]; then
        echo "LS_COLORS already exists but doesn't seem to be installed."
        if lscolors::delete; then
            lscolors::download && lscolors::install
        elif lscolors::reinstall; then
            :
        else
            echo "Error: Reinstallation and/or deletion have been aborted." >&2
        fi
    fi
fi
