# shellcheck shell=bash
#
# Utility functions and settings

# Copies a file or directory to a temporary location.
# Globals:
#   None
# Arguments:
#   $1: a file or directory to be copied into 
#   $2: the parent directory to use; defaults to $HOME if empty
# Returns:
#   0: $1 was successfully copied to a temporary location
#   1: $1 was not supplied
function utils::copy_tmp() {
    # $1 must not be empty.
    if [ -z "$1" ]; then
        echo "\$1 is empty; supply a file name. Aborting copy_tmp()." >&2
        return 1
    elif [ ! -e "$1" ]; then
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

    local tmp
    tmp=$(mktemp --tmpdir="$out_dir" -d)
    # Even for regular files, the recursive flag should be fine.
    cp --recursive "$1" "$tmp"
    echo "Saved ${1} to ${tmp}"
}
