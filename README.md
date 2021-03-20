# Home

## Overview

This is my personal home setup. Most of the modules within [.bashrc.d] come with utility functions. For easy access to these modules, run the [install.sh] script.

### GNU Coreutils focused

The commands and modules are written specifically with GNU extended commands in mind, not strictly POSIX. For example, I expressly use long flags whenever possible to reduce ambiguity. This means the project may not work outside of Linux with GNU coreutils. I am aware this reduces portability; for me, this is an acceptable trade-off.

### Style guide

I have mostly followed the [Google Style Guide for Shell] for style and documenting my modules.

Where I differ from the style guide:

- "Docstrings" do not have enclosing lines.
- All `echo` statements in functions are redirected to `STDERR`, regardless if the message was an error or not.

### Linting

All the scripts in the project are linted with `shellcheck`. Some warnings or errors are suppressed using in-line directives. For others, I have my settings listed [here](https://github.com/cj-wong/linter_settings/blob/master/linters/shellcheckrc). I try to work out those issues first (given the useful suggestions on `shellcheck`'s wiki) rather than suppressing, but sometimes suppression is necessary.

## Usage

Run `bash install.sh` or `./install.sh` to get started. [install.sh] will automatically try linking all allowed files from this project to the home directory. Some files will be excluded in the process:

- directories like `.git`
- files like the installation script itself and the documents (like this readme)
- files that match patterns in [.gitignore]

*However,* existing files with the same name (or existing sym-links that don't resolve to this project's files) will be copied to a temporary location in your home directory. (See `utils::copy_tmp()` in [_utils.bashrc].)

Most, if not all, of the functions sourced from each module are prefixed with a module name and two colons. e.g. `git::` is used to prefix functions in [git.bashrc]. To use these functions easily in vanilla Bash, simply begin the command prefixed with quotations (`"`), enter the prefix including the colons, and hit <kbd>Tab</kbd>. For example, if you wanted to use `utils::copy_tmp()`, you would type `"utils::`<kbd>Tab</kbd>.

## Requirements

Currently, `git` is required for Home, because it is used in multiple modules (especially [git.bashrc]). `git` should be already installed by default on Linux systems. It may not be necessary for most modules, but it will help keep the modules up-to-date with versioning anyway.

- `git`
    - [git.bashrc] \(not all functions will work without `jq`)
    - [ls_colors.bashrc]
- `jq`
    - [git.bashrc] \(identity management)
    - [scanimage.bashrc] \(default scan options)
- `keychain`
    - [keychain.bashrc]
- `wsl.exe` (special case)
    - [wsl.bashrc]

## Disclaimer

This project is not affiliated with or endorsed by any of the programs used by the modules, which is including but not limited to:

- [git]
- [Keychain]
- trapd00r/[LS_COLORS]
- [Windows Subsystem for Linux]

See [LICENSE](LICENSE) for more detail.

[git]: https://git-scm.com/
[Google Style Guide for Shell]: https://google.github.io/styleguide/shellguide.html
[Keychain]: https://www.funtoo.org/Keychain
[LS_COLORS]: https://github.com/trapd00r/LS_COLORS
[Windows Subsystem for Linux]: https://docs.microsoft.com/en-us/windows/wsl/
[.bashrc.d]: .bashrc.d
[.gitignore]: .gitignore
[install.sh]: install.sh
[_utils.bashrc]: .bashrc.d/_utils.bashrc
[git.bashrc]: .bashrc.d/git.bashrc
[keychain.bashrc]: .bashrc.d/keychain.bashrc
[ls_colors.bashrc]: .bashrc.d/ls_colors.bashrc
[scanimage.bashrc]: .bashrc.d/scanimage.bashrc
[wsl.bashrc]: .bashrc.d/wsl.bashrc
