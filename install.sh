#!/usr/bin/env bash
#
# Installs core files in Home to user home.
# As a pre-run condition, runs ./bashrc.d.sh.

REPO_DIR=$(dirname $0)
LAST_DIR=$(pwd)

cd "$REPO_DIR"
REPO_DIR=$(pwd)

"${REPO_DIR}/bashrc.d.sh"

DIR_BLACKLIST=(
    ".git"
)

FILE_BLACKLIST=(
    "bashrc.d.sh"
    "install.sh"
)

for file in * .[^.]*; do
    echo "Checking ${file}..."
    home_file="${HOME}/${file}"
    repo_file="${REPO_DIR}/${file}"
    if [[ -d "$file" && "${DIR_BLACKLIST[@]}" =~ "$file" ]]; then
        echo "${file} is in the blacklist for directories. Skipping."
        continue
    elif [[ -f "$file" && "${FILE_BLACKLIST[@]}" =~ "$file" ]]; then
        echo "${file} is in the blacklist for files. Skipping."
        continue
    fi

    if [ -h "$home_file" ]; then
        resolved=$(readlink "$home_file")
        if [ ! -z "$resolved" ]; then
            if [ "$resolved" = "$repo_file" ]; then
                echo "${home_file} already points to the right file. Skipping."
                continue
            else
                echo "${home_file} points to a different file."
                echo "It will be moved."
                copy_tmp "$home_file"
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

cd "$LAST_DIR"
