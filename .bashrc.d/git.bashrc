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
        local KEY="$HOME/.ssh/$1"
        if [ ! -f "$KEY" ]; then
            echo "$1 is not a valid ssh private key."
            echo "Please supply a name or location of the private key."
            return 1
        fi
    else
        local KEY="$1"
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
    local GLOBAL_NAME=$(git config --global user.name)
    local GLOBAL_EMAIL=$(git config --global user.email)
    echo "Global identity"
    echo "- Name: '${GLOBAL_NAME}'"
    echo "- Email: ${GLOBAL_EMAIL}"
    echo
    git status 2>&1 > /dev/null
    if [[ $? = 0 ]]; then
        local CURRENT_NAME=$(git config user.name)
        local CURRENT_EMAIL=$(git config user.email)
        echo "Current identity"
        echo "- Name: '${CURRENT_NAME}'"
        echo "- Email: ${CURRENT_EMAIL}"
        if [ "$GLOBAL_NAME" = "$CURRENT_NAME" ]; then
            if [ "$GLOBAL_EMAIL" = "$CURRENT_EMAIL" ]; then
                echo
                echo "The two identities are the same."
            fi
        fi
    else
        echo "Because you are not in a git repo,"
        echo "you do not have a current identity."
        return 1
    fi
}

# Show all configured identities from ~/.bashrc.d/git/identities/identities.json
# Globals:
#   IDENTITIES: an associative array with emails as keys and names as values
# Arguments:
#   None
# Returns:
#   0: if no errors occurred
function git_show_all_identities() {
    local email
    for email in "${!IDENTITIES[@]}"; do
        echo "Name: '${IDENTITIES[${email}]}'"
        echo "Email: ${email}"
        echo
    done
}

# Specify an email by providing a pattern to grep email in IDENTITIES
# Globals:
#   IDENTITIES: an associative array with emails as keys and names as values
# Arguments:
#   $1: a pattern that should match only one email address; must not be empty
# Returns:
#   0: if a match was found and the identity was set
#   1: if a pattern ($1) was not supplied
#   2: if the pattern matched multiple emails
function git_specify_identity() {
    if [ -z "$1" ]; then
        echo "\$1 is empty; supply an identity pattern."
        echo "Aborting git_specify_identity()."
        return 1
    fi

    local email
    local matched_name
    local matched_email
    for email in "${!IDENTITIES[@]}"; do
        grep "$1" <(echo "$email") 2>&1 > /dev/null
        if [[ $? = 0 ]]; then
            if [ ! -z "$matched_email" ]; then
                echo "Your pattern ($1) matches too many emails."
                echo "Aborting git_specify_identity()."
                return 2
            else
                matched_email="$email"
                matched_name="${IDENTITIES[${email}]}"
            fi
        fi
    done

    git config user.name "$matched_name"
    git config user.email "$matched_email"

    echo "Your current git identity has been set:"
    echo "- Name: '${matched_name}'"
    echo "- Email: ${matched_email}"
}

# Module-level code

JSON="${HOME}/.bashrc.d/git/identities/identities.json"

command -v jq 2>&1 > /dev/null
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
        # Because names are less unique than email addresses,
        # email is the key for the associative array.
        IDENTITIES["$email"]="$name"
    # jq will concatenate the .name and .email fields with a '/'.
    done < <(jq -r -c '.[] | (.name + "/" + .email)' "$JSON") 2>&1

    export IDENTITIES
fi
