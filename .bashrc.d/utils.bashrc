#!/usr/bin/env bash
#
# Utility functions and settings

# Copies a file to a temporary location, given a directory and filename.
# Globals:
#   None
# Arguments:
#   $1: location of the file to copy to a temporary location;
#       must contain filename and directory
#   $2: the directory to use; defaults to $HOME if empty
# Returns:
#   0: if no errors occurred
#   1: if a file ($1) was not supplied
function copy_tmp() {
    # $1 must not be empty.
    if [ -z "$1" ]; then
        echo "\$1 is empty; supply a file name. Aborting copy_tmp()."
        return 1
    elif [ ! -f "$1" ]; then
        echo "\$1 doesn't exist. You supplied '$1'".
        return 1
    fi

    # $2 can be optional.
    if [ -z "$2" ]; then
        echo "\$2 is empty; assuming \$HOME as directory."
        local OUT_DIR="$HOME"
    else
        local OUT_DIR="$2"
    fi

    local OLD
    OLD=$(mktemp -p "$OUT_DIR")
    cp "$1" "$OLD"
    echo "Saved ${1} to ${OLD}"
}
