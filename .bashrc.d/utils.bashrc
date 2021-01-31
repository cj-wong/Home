#!/bin/false
# shellcheck shell=bash
#
# Utility functions and settings
#
# Error messages in this module _should_ include the name of the function.

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
        echo "Error [utils::copy_tmp]: \$1 is empty; supply a file name." >&2
        return 1
    elif [ ! -e "$1" ]; then
        echo "Error [utils::copy_tmp]: ${1} doesn't exist." >&2
        return 1
    fi

    local out_dir

    # $2 can be optional.
    if [ -z "$2" ]; then
        echo "\$2 is empty; assuming \$HOME as parent directory." >&2
        out_dir="$HOME"
    else
        out_dir="$2"
    fi

    local tmp
    tmp=$(mktemp --tmpdir="$out_dir" --directory)
    # Even for regular files, the recursive flag should be fine.
    cp --recursive "$1" "$tmp"
    echo "Copied ${1} to ${tmp}." >&2
}

# Change directory to one that matches today's date.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the current directory could be changed to one with the current date
#   1: the directory could not be changed; the directory may not exist or
#      the user has insufficient permissions to enter it
function utils::cd_today() {
    if cd "$(date +"%Y-%m-%d")"; then
        return 0
    else
        return 1
    fi
}

# Make a directory given today's date relative to current directory.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the directory could be created successfully
#   1: the directory could not be created; the directory exists or another
#      error has prevented the creation of the directory
function utils::mkdir_today() {
    if mkdir "$(date +"%Y-%m-%d")"; then
        return 0
    else
        return 1
    fi
}

# Gets line-by-line of running processes matching arguments.
# Globals:
#   None
# Arguments:
#   $@: args to be fed to grep
# Returns:
#   0: process matched
function utils::psgrep() {
    # shellcheck disable=SC2009
    # The use of "$@" twice is somewhat hacky but evidently re-colorizes output.
    ps aux | grep "$@" | grep --invert-match grep | grep "$@"
}
