# shellcheck shell=bash
#
# Companion script for:
#   https://www.funtoo.org/Keychain
# Keys may be excluded in .bashrc.d/keycdhain/exclusions.txt, one per line.

# Load list of keys to exclude from .bashrc.d/keychain/exclusions.txt.
# Only list file names, not fully qualified paths.
# Globals:
#   KEYCHAIN_EXCLUDES: an array containing names of excluded SSH keys;
#`      can be empty
# Arguments:
#   None
# Returns:
#   0: the key exclude list was loaded and exported successfully
function keychain::load_exclusions() {
    local exclusions
    exclusions="${HOME}/.bashrc.d/keychain/exclusions.txt"

    KEYCHAIN_EXCLUDES=( )

    if [ -f "$exclusions" ]; then
        while read -r excluded; do
            KEYCHAIN_EXCLUDES+=("$excluded")
        done < "$exclusions"
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
#   0: the key is to be excluded or doesn't exist or $1 is empty
#   1: the key is not excluded
function keychain::is_excluded() {
    if [ -z "$1" ]; then
        echo "\$1 is empty. Aborting keychain::is_excluded()." >&2
        return 0
    fi

    local ex_key
    for ex_key in "${KEYCHAIN_EXCLUDES[@]}"; do
        if [[ "$ex_key" == "$1" ]]; then
            echo "Excluded key: ${1}"
            return 0
        fi
    done

    return 1
}

# Load the keys and check whether they are excluded.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the keys were loaded into keychain
function keychain::load_keys() {
    local keys
    keys=( )

    keychain::load_exclusions

    local pubkey
    local privkey
    local stemkey
    for pubkey in ~/.ssh/*.pub; do
        privkey="${pubkey%.pub}"
        stemkey="${privkey##*/}"

        if keychain::is_excluded "$stemkey"; then
            continue
        elif [ -f "$privkey" ]; then
            keys+=("$privkey")
        fi
    done

    eval "$(keychain --eval --agents ssh --clear "${keys[@]}")"
}

# Module-level code

if ! command -v keychain > /dev/null 2>&1; then
    echo "keychain is not installed. Aborting keychain.bashrc."
elif [ -n "$SSH_CLIENT" ]; then
    echo "keychain will not start in SSH sessions." >&2
    echo "Aborting keychain.bashrc." >&2
else
    keychain::load_keys
fi
