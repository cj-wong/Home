# shellcheck shell=bash
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
#   0: no errors occurred
#   1: a file ($1) was not supplied
function utils::copy_tmp() {
    # $1 must not be empty.
    if [ -z "$1" ]; then
        echo "\$1 is empty; supply a file name. Aborting copy_tmp()." >&2
        return 1
    elif [ ! -f "$1" ]; then
        echo "\$1 doesn't exist. You supplied '$1'." >&2
        return 1
    fi

    local out_dir

    # $2 can be optional.
    if [ -z "$2" ]; then
        echo "\$2 is empty; assuming \$HOME as directory."
        out_dir="$HOME"
    else
        out_dir="$2"
    fi

    local old
    old=$(mktemp -p "$out_dir")
    cp "$1" "$old"
    echo "Saved ${1} to ${old}"
}
