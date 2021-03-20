#!/bin/false
# shellcheck shell=bash
#
# The first module to be sourced from .bashrc.d.
#
# This module contains shared configuration between modules and first-run
# checks.
#
# This module will be unconditionally sourced. It does not need to be enabled.

# Check whether an app (program) is installed.
#
# Globals:
#   None
# Arguments:
#   $1: the name of a program or applet
# Returns:
#   0: the prerequisite app is installed
#   1: it isn't installed
function home::app_is_installed() {
    if command -v "$1" > /dev/null 2>&1; then
        return 0
    else
        echo "Error: ${1} is not installed." >&2
        return 1
    fi
}

# Load enabled modules for .bashrc.d.
#
# The following modules are unconditionally enabled:
# - 0.bashrc (this file)
# - _aliases_and_vars.bashrc
# - _utils.bashrc
#
# All other modules must be manually enabled in the file.
#
# Each entry in modules/enabled.txt should not include the .bashrc extension.
#
# Globals:
#   HOME_MODULES: an array containing names of enabled .bashrc.d modules;
#`      can be empty
# Arguments:
#   None
# Returns:
#   0: the key exclude list was loaded and exported successfully
function home::load_enabled_modules() {
    echo "Loading modules to be enabled..." >&2
    local enabled_list
    enabled_list="${HOME}/.bashrc.d/0/modules/enabled.txt"

    HOME_MODULES=( )

    if [ -f "$enabled_list" ]; then
        while read -r enabled; do
            HOME_MODULES+=("$enabled")
        done < "$enabled_list"
    fi

    export HOME_MODULES
    echo "Modules to be enabled: ${HOME_MODULES[*]}" >&2
}

# Check whether a .bashrc.d module is enabled.
#
# Globals:
#   HOME_MODULES: an array containing names of excluded SSH keys;
#`      can be empty
# Arguments:
#   $1: a module to check; must only be the file name without .bashrc extension
# Returns:
#   0: the module was enabled
#   1: the module was not enabled
#   2: $1 is empty
function home::module_is_enabled() {
    if [ -z "$1" ]; then
        echo "Error: \$1 is empty." >&2
        return 2
    fi

    if [[ "$1" == "_aliases_and_vars" || "$1" == "_utils" ]]; then
        return 0
    fi

    local module
    for module in "${HOME_MODULES[@]}"; do
        if [[ "$module" == "$1" ]]; then
            return 0
        fi
    done

    return 1
}

# Module-level code

home::load_enabled_modules
