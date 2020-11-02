# shellcheck shell=bash
#
# Companion script for: https://www.funtoo.org/Keychain

EXCLUSIONS="${HOME}/.bashrc.d/keychain/exclusions.txt"

# Load list of keys to exclude from .bashrc.d/keychain/exclusions.txt.
# Only list file names, not fully qualified paths.
# Globals:
#   KEYCHAIN_EXCLUDES: an array containing names of excluded SSH keys;
#`      can be empty
# Arguments:
#   None
# Returns:
#   0: if no errors occurred
function load_exclusions() {
    KEYCHAIN_EXCLUDES=( )

    if [ -f "$EXCLUSIONS" ]; then
        while read -r excluded; do
            KEYCHAIN_EXCLUDES+=("$excluded")
        done < "$EXCLUSIONS"
    fi

    export KEYCHAIN_EXCLUDES
}

# Check whether a SSH key was excluded for use in keychain.
# Globals:
#   KEYCHAIN_EXCLUDES: an array containing names of excluded SSH keys;
#`      can be empty
# Arguments:
#   $1: a key to check; must only be the file name
# Returns:
#   0: if the key is not in the exclusion list
#   1: if the key is to be excluded
#   2: if $1 is empty
function is_excluded() {
    if [ -z "$1" ]; then
        echo "$1"
        return 2
    fi

    local ex_key
    for ex_key in "${KEYCHAIN_EXCLUDES[@]}"; do
        if [[ "$ex_key" == "$1" ]]; then
            return 1
        fi
    done

    return 0
}

# Module-level code

if ! command -v keychain > /dev/null 2>&1; then
    echo "keychain is not installed. Aborting keychain.bashrc."
elif [ -n "$SSH_CLIENT" ]; then
    echo "keychain will not start in SSH sessions. Aborting keychain.bashrc."
else
    KEYS=( )

    load_exclusions

    for pubkey in ~/.ssh/*.pub; do
        privkey="${pubkey%.pub}"
        stemkey="${privkey##*/}"

        if ! is_excluded "$stemkey"; then
            echo "Excluded key: ${privkey}"
            continue
        elif [ -f "$privkey" ]; then
            KEYS+=("$privkey")
        fi
    done

    eval "$(keychain --eval --agents ssh --clear "${KEYS[@]}")"
fi
