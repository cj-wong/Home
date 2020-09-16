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
        echo "\$1 is empty; supply a private key. Aborting git.bashrc."
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

# Show the current identity along with global identity of current repo
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if the command was run in a git repo
#   1: if the command wasn't run in a git repo
function git_show_identity() {
    GLOBAL_NAME=$(git config --global user.name)
    GLOBAL_EMAIL=$(git config --global user.email)
    echo "Global identity"
    echo "- Name: '${GLOBAL_NAME}'"
    echo "- Email: ${GLOBAL_EMAIL}"
    echo
    git status > /dev/null 2&>1
    if [[ $? = 0 ]]; then
        CURRENT_NAME=$(git config user.name)
        CURRENT_EMAIL=$(git config user.email)
        echo "Current identity"
        echo "- Name: '${CURRENT_NAME}'"
        echo "- Email: ${CURRENT_EMAIL}"
    else
        echo "Because you are not in a git repo,"
        echo "you do not have a current identity."
        return 1
    fi
}

# Module-level code

JSON="${HOME}/.bashrc.d/git/identities/identities.json"

command -v jq 2&> /dev/null
if [[ $? != 0 ]]; then
    echo "jq is not installed. Install jq to enable identity management."
elif [ ! -f "$JSON" ]; then
    echo "identities.json doesn't exist in ${HOME}/.bashrc.d/git/identities/."
    echo "Create one to enable identity management."
else
    declare -A IDENTITIES

    while read -r identity; do
        # With the concatenation separator (see below), we can extract
        # the name and email of this pair.
        name=$(echo "$identity" | cut -d/ -f1)
        email=$(echo "$identity" | cut -d/ -f2)
        if [ -z "$name" -o -z "$email" ]; then
            echo "Skipping key pair with missing name or email."
            echo "Reference: ${name}${email}"
            continue
        fi
        IDENTITIES["$name"]="$email"
    # jq will concatenate the .name and .email fields with a '/'.
    done < <(jq -c '.[] | (.name + "/" + .email') 2>&1

    export IDENTITIES
fi
