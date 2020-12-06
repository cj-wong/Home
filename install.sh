#!/usr/bin/env bash
#
# Installs core files in Home to user home.
# As a pre-run condition, runs ./bashrc.d.sh.
#
# Exit codes:
#   1: normal installation aborted
#   2: partial installation aborted (.bashrc.d code block in .bashrc)

# Checks whether a file should be excluded from linking by checking
# contents of the project .gitignore.
# Globals:
#   EXCLUDE_GITIGNORE: an array of patterns in .gitignore; this array is only
#       populated in the middle of this script so the function should not be
#       called on its own elsewhere
# Arguments:
#   $1: the file to check
# Returns:
#   0: the file should be ignored and not linked
#   1: the file can be safely linked
function is_file_gitignored() {
    for ignore in "${EXCLUDE_GITIGNORE[@]}"; do
        # shellcheck disable=SC2053
        # This function specifically depends on wildcard matching and
        # will not work when quoted.
        if [[ "$1" == $ignore ]]; then
            echo "$ignore"
            return 0
        fi
    done

    return 1
}


REPO_DIR=$(dirname "$0")
LAST_DIR=$(pwd)

echo "Moving into ${REPO_DIR} ..."

pushd "$REPO_DIR" > /dev/null \
    || (echo "Could not go into ${REPO_DIR}. Aborting." && exit 1)
REPO_DIR=$(pwd)

INSTALL_BLOCK=$(cat <<END
if [ -d ~/.bashrc.d ]; then
    for file in ~/.bashrc.d/*.bashrc; do
        . "\$file"
    done
fi
END
)

# If copy_tmp isn't available, source it from the utils file.
if ! type -t "utils::copy_tmp" > /dev/null 2>&1; then
    . "$(dirname "$0")/.bashrc.d/utils.bashrc"
fi

if [[ $(< "${HOME}/.bashrc") != *"$INSTALL_BLOCK"* ]]; then
    echo ".bashrc.d functionality was not detected in your .bashrc file."
    echo "If installed, your old .bashrc will be saved to a temporary file."
    read -r -p "Do you wish to install? [yN] " prompt
    if [[ $prompt =~ ^[yY] ]]; then
        copy_tmp ~/.bashrc
        echo "$INSTALL_BLOCK" >> ~/.bashrc
        echo "Installed .bashrc.d into your .bashrc file. Restart shell to use."
    else
        echo "Aborting installation." >&2
        popd > /dev/null || echo "Could not return to ${LAST_DIR}." >&2
        exit 1
    fi
else
    echo ".bashrc.d functionality is already detected."
    read -r -p "Continue with file linking? [yN] " prompt
    if [[ ! $prompt =~ ^[yY] ]]; then
        echo "Aborting installation." >&2
        popd > /dev/null || echo "Could not return to ${LAST_DIR}." >&2
        exit 2
    fi
fi

EXCLUDE_DIRS=(
    ".git"
)

EXCLUDE_FILES=(
    ".gitignore"
    "install.sh"
    "LICENSE"
    "README.md"
)

while read -r line; do
    EXCLUDE_GITIGNORE+=("$line")
done < "${REPO_DIR}/.gitignore"

echo "Linking files from project root to ~/.bashrc.d..."

for file in * .[^.]*; do
    echo "Checking ${file}..."
    home_file="${HOME}/${file}"
    repo_file="${REPO_DIR}/${file}"
    if [[ -d "$file" && "${EXCLUDE_DIRS[*]}" =~ $file ]]; then
        echo "${file} is a directory to be excluded. Skipping."
        continue
    elif [[ -f "$file" && "${EXCLUDE_FILES[*]}" =~ $file ]]; then
        echo "${file} is a file to be excluded. Skipping."
        continue
    elif pattern=$(is_file_gitignored "$file"); then
        echo "${file} matches a pattern [${pattern}] in .gitignore. Skipping."
        continue
    fi

    if [ -h "$home_file" ]; then
        resolved=$(readlink "$home_file")
        if [ -n "$resolved" ]; then
            if [ "$resolved" = "$repo_file" ]; then
                echo "${home_file} already points to the right file. Skipping."
                continue
            else
                echo "${home_file} points to a different file."
                echo "It will be moved."
                utils::copy_tmp "$home_file"
                rm -f "$home_file"
            fi
        fi
    elif [ -d "$home_file" ]; then
        tmp=$(mktemp -p ~ -d)
        echo "${home_file} exists and will be moved to ${tmp}."
        mv "$home_file" "$tmp"
    elif [ -e "$home_file" ]; then
        echo "${home_file} exists as a file and will be moved."
        copy_tmp "$home_file"
        rm -f "$home_file"
    fi
    ln -s "$repo_file" ~
done

echo "Changing repository directory permissions to 700."
chmod 700 "$REPO_DIR"

popd > /dev/null || cd "$LAST_DIR" || echo "Could not return to original directory."
