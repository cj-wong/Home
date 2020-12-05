# Home

## Overview

This is my personal home setup. Most of the modules within [.bashrc.d] come with related functions (mostly utilities). For easy access to these scripts, run the [install.sh] script.

## Usage

Run `bash install.sh` or `./install.sh` to get started. [install.sh] will automatically try linking all allowed files from this project to the home directory. Some files will be excluded in the process:

- directories like `.git`
- files like the installation script itself and the documents (like this readme)
- files that match patterns in [.gitignore]

*However,* existing files with the same name (and existing symlinks that don't resolve to this project's files) will be moved to temporary files. (See `utils::copy_tmp` in [utils.bashrc].)

Most, if not all, of the functions sourced from each module are prefixed with a module name and two colons. e.g. `git::` is used to prefix functions in [git.bashrc]. To use these functions easily in vanilla Bash, simply begin the command prefixed with quotations (`"`), enter the prefix including the colons, and hit <kbd>Tab</kbd>. For example, if you wanted to use `utils::copy_tmp`, you would type `"utils::`<kbd>Tab</kbd>.

[.bashrc.d]: .bashrc.d
[.gitignore]: .gitignore
[install.sh]: install.sh
[git.bashrc]: .bashrc.d/git.bashrc
[utils.bashrc]: .bashrc.d/utils.bashrc
