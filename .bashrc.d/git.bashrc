# shellcheck shell=bash
#
# Functions (helper and shortcuts) for git

# Checks whether the working directory is a git repository.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the directory is a git repository
#   1: directory is not a git repository
function git::is_repo() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 0
    else
        echo "${PWD} is not a git repository." >&2
        return 1
    fi
}

# Changes ssh key used for git.
# Globals:
#   None
# Arguments:
#   $1: location or filename of the ssh private key
# Returns:
#   0: the ssh key was successfully applied
#   1: a file ($2) was not supplied
#   255: not run within a git repository
function git::specify_key() {
    if ! git::is_repo; then
        return 255
    elif [ -z "$1" ]; then
        echo "Error: \$1 is empty; supply a private key." >&2
        return 1
    elif [ ! -f "$1" ]; then
        local KEY="$HOME/.ssh/$1"
        if [ ! -f "$KEY" ]; then
            echo "Error: $1 is not a valid ssh private key." >&2
            echo "Please supply a name or location of the private key." >&2
            return 1
        fi
    else
        local KEY
        KEY="$1"
    fi

    echo "Using ${KEY} for current repository."
    git config core.sshCommand "ssh -i $KEY"
}

# Show the current identity along with global identity of current repo
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the command was run in a git repo
#   255: the command wasn't run in a git repo
function git::show_identity() {
    local global_name
    local global_email
    global_name=$(git config --global user.name)
    global_email=$(git config --global user.email)
    echo "Global identity"
    echo "- Name: '${global_name}'"
    echo "- Email: ${global_email}"
    echo
    if git::is_repo > /dev/null; then
        local current_name
        local current_email
        current_name=$(git config user.name)
        current_email=$(git config user.email)
        echo "Current identity"
        echo "- Name: '${current_name}'"
        echo "- Email: ${current_email}"
        if [ "$global_name" = "$current_name" ]; then
            if [ "$global_email" = "$current_email" ]; then
                echo
                echo "The two identities are the same."
            fi
        fi
    else
        echo "Because you are not in a git repo," >&2
        echo "you do not have a current identity." >&2
        return 255
    fi
}

# Show all configured identities from ~/.bashrc.d/git/identities/identities.json
# Globals:
#   IDENTITIES: an associative array with emails as keys and names as values
# Arguments:
#   None
# Returns:
#   0: no errors occurred
function git::show_all_identities() {
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
#   0: the pattern matched a single email and the identity was set
#   1: a pattern ($1) was not supplied
#   2: the pattern matched multiple emails
#   3: no identities were matched
#   255: not run in a git repository
function git::specify_identity() {
    if ! git::is_repo; then
        return 255
    elif [ -z "$1" ]; then
        echo "\$1 is empty; supply an identity pattern." >&2
        echo "Aborting git::specify_identity()." >&2
        return 1
    fi

    local email
    local matched_name
    local matched_email

    for email in "${!IDENTITIES[@]}"; do
        if grep "$1" <(echo "$email") > /dev/null 2>&1; then
            if [ -n "$matched_email" ]; then
                echo "Your pattern ($1) matches too many emails." >&2
                echo "Aborting git::specify_identity()." >&2
                return 2
            else
                matched_email="$email"
                matched_name="${IDENTITIES[${email}]}"
            fi
        fi
    done

    if [ -z "${matched_name+x}" ]; then
        echo "Could not match any identities."
        return 3
    fi

    git config user.name "$matched_name"
    git config user.email "$matched_email"

    echo "Your current git identity has been set:"
    echo "- Name: '${matched_name}'"
    echo "- Email: ${matched_email}"
}

# Add a new remote to a project for simultaneous pushes
# Globals:
#   None
# Arguments:
#   $1: a git remote repository
# Returns:
#   0: the new remote was added successfully
#   1: $1 was not supplied
#   2: a remote wasn't set already and user canceled adding $1 as new remote
#   255: not run within a git repository
function git::add_remote() {
    if ! git::is_repo; then
        return 255
    elif [ -z "$1" ]; then
        echo "Error: \$1 is empty; supply a remote git repository." >&2
        return 1
    fi

    if git remote set-url --add --push origin "$1"; then
        :
    else
        # fatal: No such remote 'origin'
        echo "No remote origin was set." >&2
        read -r -p "Do you want to set ${1} as your remote? [yN] " prompt
        if [[ $prompt =~ ^[yY] ]]; then
            git remote add origin "$1"
            git remote set-url --add --push origin "$1"
        else
            echo "git::add_remote has been aborted." >&2
            return 2
        fi
    fi

    return 0
}

# Add existing remote URL to pushurl for simultaneous pushes.
# Because simultaneous pushes use `set-url` instead of the default syntax,
# the existing remote must be re-added for pushes to take effect.
# Rather than have the user fetch the old remote again, it can be re-added
# by retrieval from `git config --local remote.origin.url`.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: the remote was added successfully
#   1: the repository does not have a remote origin URL
#   255: not run within a git repository
function git::readd_remote() {
    if ! git::is_repo; then
        return 255
    fi

    local url
    url=$(git config --local remote.origin.url)

    if [ -z "$url" ]; then
        echo "No existing remote origin URL was found." >&2
        echo "Aborting git::readd_remote()." >&2
        return 1
    else
        git remote set-url --add --push origin "$url"
    fi
}

# Read identities from file and export them to an array.
# It appears that the `-A` flag of `declare` is specific to GNU,
# so this function may not work on POSIX-only.
# Globals:
#   GIT_ID_FILE: JSON where the identities are stored
#   IDENTITIES: an associative array with emails as keys and names as values
# Arguments:
#   None
# Returns:
#   0: the identities were read into environment variables
#   255: jq is not installed
function git::read_identities() {
    if ! home::app_is_installed jq; then
        return 255
    fi

    declare -A IDENTITIES

    local identity
    local name
    local email
    local delimiter

    delimiter="/"

    while read -r identity; do
        # With the concatenation separator ($delimiter), we can extract
        # the name and email of this pair.
        name=$(echo "$identity" | cut --delimiter="$delimiter" --fields=1)
        email=$(echo "$identity" | cut --delimiter="$delimiter" --fields=2)
        if [[ -z "$name" || -z "$email" ]]; then
            echo "Skipping key pair with missing name or email." >&2
            echo "Reference: ${name}${email}" >&2
            continue
        fi
        # Because names are less unique than email addresses,
        # email is the key for the associative array.
        IDENTITIES["$email"]="$name"
    # jq will concatenate the .name and .email fields with $delimiter above.
    done < <(jq --raw-output --compact-output \
        ".[] | (.name + \"$delimiter\" + .email)" "$GIT_ID_FILE") 2>&1

    # Bash currently cannot export associative arrays from within functions.
    # To bypass this, we can export the array to a file and then source it.
    declare -p IDENTITIES > "$GIT_ID_SH"

    # Tell user to manually source the new file, since this function
    # cannot load identities itself.
    echo "To reload your identities, run this command:"
    echo ". ${GIT_ID_SH}"
}

# Module-level code

GIT_ID_DIR="${HOME}/.bashrc.d/git/identities"
GIT_ID_SH="${GIT_ID_DIR}/identities.sh"
GIT_ID_FILE="${GIT_ID_DIR}/identities.json"

if ! home::app_is_installed jq; then
    echo "Install jq to enable identity management." >&2
elif [ ! -f "$GIT_ID_FILE" ]; then
    echo "identities.json doesn't exist in ${GIT_ID_DIR}." >&2
    echo "Create it to enable identity management." >&2
else
    git::read_identities > /dev/null
    . "$GIT_ID_SH" && export IDENTITIES
fi
