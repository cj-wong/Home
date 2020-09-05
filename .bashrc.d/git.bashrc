#!/usr/bin/env bash
#
# Functions (helper and shortcuts) for git

# Changes ssh key used for git.
# Globals:
#   None
# Arguments:
#   $1: location or filename of the ssh private key
# Returns:
#   0: if no errors occurred
#   1: if a file ($2) was not supplied
function git_specify_key() {
    if [ -z "$1" ]; then
        echo "\$1 is empty; supply a private key. Aborting script."
        return 1
    elif [ ! -f "$1" ]; then
        KEY="$HOME/.ssh/$1"
        if [ ! -f "$KEY" ]; then
            echo "$1 is not a valid ssh private key."
            echo "Please supply a name or location of the private key."
            return 1
        fi
    else
        KEY="$1"
    fi

    git config core.sshCommand "ssh -i $KEY"
}
