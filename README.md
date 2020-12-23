# Home

## Overview

This is my personal home setup. Most of the modules within [.bashrc.d] come with related functions (mostly utilities). For easy access to these scripts, run the [install.sh] script.

## Usage

Run `bash install.sh` or `./install.sh` to get started. [install.sh] will automatically try linking all allowed files from this project to the home directory. Some files will be excluded in the process:

- directories like `.git`
- files like the installation script itself and the documents (like this readme)
- files that match patterns in [.gitignore]

*However,* existing files with the same name (or existing symlinks that don't resolve to this project's files) will be moved to temporary files. (See `utils::copy_tmp()` in [utils.bashrc].)

Most, if not all, of the functions sourced from each module are prefixed with a module name and two colons. e.g. `git::` is used to prefix functions in [git.bashrc]. To use these functions easily in vanilla Bash, simply begin the command prefixed with quotations (`"`), enter the prefix including the colons, and hit <kbd>Tab</kbd>. For example, if you wanted to use `utils::copy_tmp`, you would type `"utils::`<kbd>Tab</kbd>.

## Requirements

Currently, `git` is required for Home, because it is used in multiple modules (especially [git.bashrc]).

## Disclaimer

This project is not affiliated with or endorsed by any of the programs used by the modules, which is including but not limited to:

- [git]
- [Keychain]
- trapd00r/[LS_COLORS]
- [Microsoft] - [WSL]

See [LICENSE](LICENSE) for more detail.

[git]: https://git-scm.com/
[Keychain]: https://www.funtoo.org/Keychain
[LS_COLORS]: https://github.com/trapd00r/LS_COLORS
[Microsoft]: https://microsoft.com
[WSL]: https://docs.microsoft.com/en-us/windows/wsl/
[.bashrc.d]: .bashrc.d
[.gitignore]: .gitignore
[install.sh]: install.sh
[git.bashrc]: .bashrc.d/git.bashrc
[utils.bashrc]: .bashrc.d/utils.bashrc
