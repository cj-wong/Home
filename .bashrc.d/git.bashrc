#!/usr/bin/env bash
#
# Functions (helper and shortcuts) for git

# Checks whether the working directory is a git repository.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if the directory is a git repository
#   1: not a git repository
function git_is_repo() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 0
    else
        echo "This is not a git repository." 1>&2
        return 1
    fi
}

# Changes ssh key used for git.
# Globals:
#   None
# Arguments:
#   $1: location or filename of the ssh private key
# Returns:
#   0: if no errors occurred
#   1: if a file ($2) was not supplied
#   255: if not run within a git repository
function git_specify_key() {
    if ! git_is_repo; then
        return 255
    elif [ -z "$1" ]; then
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
#   255: if the command wasn't run in a git repo
function git_show_identity() {
    local GLOBAL_NAME
    local GLOBAL_EMAIL
    GLOBAL_NAME=$(git config --global user.name)
    GLOBAL_EMAIL=$(git config --global user.email)
    echo "Global identity"
    echo "- Name: '${GLOBAL_NAME}'"
    echo "- Email: ${GLOBAL_EMAIL}"
    echo
    if git_is_repo > /dev/null; then
        local CURRENT_NAME
        local CURRENT_EMAIL
        CURRENT_NAME=$(git config user.name)
        CURRENT_EMAIL=$(git config user.email)
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
        return 255
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
#   255: if not run in a git repository
function git_specify_identity() {
    if ! git_is_repo; then
        return 255
    elif [ -z "$1" ]; then
        echo "\$1 is empty; supply an identity pattern."
        echo "Aborting git_specify_identity()."
        return 1
    fi

    local email
    local matched_name
    local matched_email
    for email in "${!IDENTITIES[@]}"; do
        grep "$1" <(echo "$email") > /dev/null 2>&1
        if grep "$1" <(echo "$email") > /dev/null 2>&1; then
            if [ -n "$matched_email" ]; then
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

# Add a new remote to a project for simultaneous pushes
# Arguments:
#   $1: a git remote repository
# Returns:
#   0: if the origin was added successfully
#   1: if $1 was not supplied
#   2: if an origin wasn't set already and user canceled adding $1 as new origin
#   255: if not run within a git repository
function git_add_origin() {
    if ! git_is_repo; then
        return 255
    elif [ -z "$1" ]; then
        echo "\$1 is empty; supply a remote git repository."
        echo "Aborting git_add_origin()."
        return 1
    fi

    if git remote set-url --add --push origin "$1"; then
        :
    else
        local e
        e="$?"
        if [[ "$e" == 128 ]]; then
            # fatal: No such remote 'origin'
            echo "No origin was set."
            read -r -p "Do you want to set ${1} as your origin?" prompt
            if [[ $prompt =~ ^[yY] ]]; then
                git remote add origin "$1"
                git remote set-url --add --push origin "$1"
            else
                echo "Aborting git_add_origin()."
                return 2
            fi
        fi
    fi

    return 0
}

# Add existing remote URL to pushurl for simultaneous pushes
# Arguments:
#   None
# Returns:
#   0: if the origin was added successfully
#   1: if the repository does not have a remote origin URL
#   255: if not run within a git repository
function git_readd_origin() {
    if ! git_is_repo; then
        return 255
    fi

    local url
    url=$(git config --local remote.origin.url)

    if [ -z "$url" ]; then
        echo "No existing remote origin URL was found."
        echo "Aborting git_seturl_origin()."
        return 1
    else
        git remote set-url --add --push origin "$url"
    fi
}

# Module-level code

JSON="${HOME}/.bashrc.d/git/identities/identities.json"

if ! command -v jq > /dev/null 2>&1; then
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
        if [[ -z "$name" || -z "$email" ]]; then
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
