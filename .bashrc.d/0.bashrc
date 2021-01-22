#!/bin/false
# shellcheck shell=bash
#
# The first module to be sourced from .bashrc.d.
# This module contains shared configuration between modules and first-run 
# checks.

# Check whether an app (program) is installed.
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
