#!/bin/false
# shellcheck shell=bash
#
# Python language utilities

# Install PyPI dependencies from requirements.txt within the current directory.
# This function does not support bare pip installs (i.e. to system) or
# conda installs (use conda directly instead).
# Globals:
#   None
# Arguments:
#   $1: (optional) the name of the virtual environment to use (defaults to venv)
# Returns:
#   0: pip packages successfully installed
#   1: one or more of the following does not exist:
#       - environment directory (wrong name?)
#       - activation script of environment (broken environment)
#       - requirements.txt
#   2: sourcing the activation script failed
function python::pip::install_here() {
    local env # Environment directory name
    local activate # Environment activation script
    if [[ -n "$1" ]]; then
        env="$1"
    else
        env="venv"
    fi

    activate="${env}/bin/activate"

    if [[ ! -f "requirements.txt" ]]; then
        echo "requirements.txt doesn't exist; no packages can be installed." \
             "Exiting..." >&2
        return 1
    elif [[ ! -d "$env" ]]; then
        echo "${env} doesn't exist. Exiting..." >&2
        return 1
    elif [[ ! -f "$activate" ]]; then
        echo "${env}/bin/activate doesn't exist. Exiting..." >&2
        echo "(Is your virtual environment broken?)" >&2
        return 1
    fi

    if . "$env"; then
        pip install -r requirements.txt
        return 0
    else
        echo "Could not source activation script. Exiting..." >&2
        return 2
    fi
}
