#!/bin/false
# shellcheck shell=bash
#
# Helper functions for scanimage.

# Load default arguments from scanimage/arguments/arguments.json.
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: default args were loaded
#   1: jq wasn't installed
#   2: the arguments file didn't exist
function scanimage::load_default_args() {
    SCANIMAGE_DEFAULT_ARGS=( )

    local file
    file="${HOME}/.bashrc.d/scanimage/arguments/arguments.json"

    if ! home::app_is_installed jq; then
        return 1
    elif [[ ! -f "$file" ]]; then
        echo "${file} doesn't exist." >&2
        return 2
    fi

    while read -r argument; do
        SCANIMAGE_DEFAULT_ARGS+=("$argument")
    done < <(jq --raw-output ".[]" "$file")

    export SCANIMAGE_DEFAULT_ARGS
}

# Scan many images until terminated with SIGINT (Ctrl-C).
#
# SIGINT is caught by `trap` and will return 0 rather than 130.
#
# Globals:
#   None
# Arguments:
#   $@: args to be fed to scanimage; if supplied, default arguments generated
#       from scanimage/arguments/arguments.json will be ignored
# Returns:
#   0: scans completed successfully
#   1: scanimage wasn't able to run; this is most likely due to incorrect args
function scanimage::scan_many() {
    local args
    local file_number # File number starting at 1; increments per loop
    local prompt

    if [[ "$*" ]]; then
        echo "Overriding default arguments with $*." >&2
        args=( "$@" )
    elif ! scanimage::load_default_args; then
        echo "No arguments will be applied to scanimage." >&2
        args=( )
    else
        args=( "${SCANIMAGE_DEFAULT_ARGS[@]}" )
    fi

    trap "echo; trap - SIGINT; return 0" SIGINT

    file_number=1
    echo "To exit, hit Ctrl-C." >&2
    while true; do
        # Prevent unintended Enter key presses to ensure scan is intended
        while [[ -z "${prompt}" ]]; do
            read -r -p "Enter anything to scan page ${file_number}: " prompt
        done
        unset prompt
        if ! scanimage "${args[@]}" > "${file_number}.pnm"; then
            echo "Could not run scanimage...exiting." >&2
            return 1
        fi
        ((file_number++))
    done
}

# Module-level code

if ! home::app_is_installed scanimage; then
    echo "[scanimage.bashrc]" \
         " Install scanimage for scanning helper functions." >&2
fi
