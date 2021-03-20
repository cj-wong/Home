# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2021-03-19
### Added
- Added [python.bashrc] for *Python* language utilities: the first utility installs *PyPI* packages from a `requirements.txt` in the current directory.
- Added a system to selectively enable modules, by creating a file `enabled.txt` in [.bashrc.d/0/modules/](.bashrc.d/0/modules/).
    - [0.bashrc], [_aliases_and_vars.bashrc], and [_utils.bashrc] will be unconditionally enabled.
    - **To enable this system, change `.bashrc` to match the new code inside `INSTALL_BLOCK` in [install.sh].**
- Added an example/template module that all new modules onward should use for reference: [__new.bashrc.enabled].
- Added an alias to [_aliases_and_vars.bashrc] that creates a limited user to use for isolating programs.

### Changed
- In [_aliases_and_vars.bashrc]:
    - Moved `.bash_aliases` to [_aliases_and_vars.bashrc]. This could be considered a breaking change, as it will invalidate existing installs' `.bash_aliases` sym-link, but since it will be sourced from [.bashrc.d], functionality should be the same.
    - Merged contents of `path.bashrc` to this file. Because `$PATH` is an environment variable and the two modules served very similar purposes, it made sense to keep them in one file only.
    - Similarly, merged contents of `prompt.bashrc` into this file.
    - `$PATH` is only modified when `~/.local/bin` isn't already present.
- 

## [0.5.0] - 2021-01-30
### Added
- Added a new function `utils::today::mkdir()` in [_utils.bashrc] that creates a directory relative to the current directory named after the day's date in the format `%Y-%m-%d`.
- Added a new function counterpart to the aforementioned function, `utils::today::cd()`, which attempts to change current directory to one matching the day's date.
- Added new module [scanimage.bashrc] for helper functions for `scanimage` scanning.
    - To add default arguments to use for `scanimage`, create a file `arguments.json` in [.bashrc.d/scanimage/arguments/](.bashrc.d/scanimage/arguments/).

### Changed
- Changed function docstrings in the following ways:
    - Cleaned up invalid references.
    - Changed verb tense in return comments to be past tense.

### Removed
- Removed `popd` calls in [install.sh], because directory changing only applies to the new subshell when running scripts.

## [0.4.1] - 2021-01-21
### Changed
- Added `#!/bin/false` shebang to all source-only scripts in [.bashrc.d]. Since all the scripts in [.bashrc.d] also lack execute permissions, the hope is to minimize the chance of executing the scripts, although `bash script.bashrc` will still work.

## [0.4.0] - 2020-12-22
### Changed
- Functions that require an installed program will now check in the beginning whether the program is installed.
- Similarly, modules have had hard-coded program checks removed in place of a function (`home::app_is_installed()`) from [0.bashrc]. `0.bashrc` is intended to be a common configuration module for the other modules, hence why its name starts with `0` (sourced first according to sorted order).
- In [git.bashrc], the delimiter in `git::read_identities()` is no longer hard-coded. It is declared in a local variable to the function.

## [0.3.8] - 2020-12-21
### Added
- Added human-readable units for `df` and `du` in [.bash_aliases].
- Added more helpful messages when executing commands.
- Added note in [install.sh] that `git` is a required command, in case Home was downloaded instead of cloned.

### Changed
- Moved `psgrep()` and renamed to `utils::psgrep()` in [.bash_aliases] to [_utils.bashrc], as `psgrep()` is not an alias.
- Error messages, instead of saying `Aborting $function`, will now be prefaced with `Error:`. However, some messages routed through `stderr` may not be errors. For instance, a user responding `no` to a prompt will cancel the function/script (and send the message to `stderr`), but the message is not an error.
    - Likewise, in module-level `.bashrc` code, some messages will not be errors when functionality is optional. For instance, [keychain.bashrc] will warn users if the session isn't through SSH and `keychain` isn't installed. However in SSH sessions, it will let the user know that `keychain` will not run (so, an error).
    - Care should be taken when considering functions called by other functions: the error message *should* reference the function name of the function that encountered an error. For example, [_utils.bashrc] functions should follow this rule, since other functions may call those utility functions.

### Fixed
- Added missing conditional to `lscolors::update`. Previously, if the directory didn't exist, the function would return 0 and not tell the user the directory was absent.

## [0.3.7] - 2020-12-06
### Changed
- Resolved #3; `utils::copy_tmp()` should now work with directories as well.
- Resolved #4; in [ls_colors.bashrc]:
    - `lscolors::ask_delete()` functionality moved into `lscolors::delete()` and module calls new delete only
    - `lscolors::ask_reinstall()` renamed `lscolors::reinstall()` and calls `lscolors::install()`
- In [git.bashrc], functions and strings that referenced `origin` were renamed to `remote` or `remote origin`. This is more consistent with what the functions manipulate.

### Fixed
- In [git.bashrc], `git::read_identities()` now lets users know how to reload identities. Because currently Bash functions cannot export associative arrays, the function must tell the user to source the file manually. This function should only be used sparingly outside of a fresh terminal, as the extra source command is required for a reload of identities.

## [0.3.6] - 2020-12-05
### Added
- Files that match patterns in `.gitignore` will no longer be linked to the home directory.

### Changed
- Mentions of "injection" have been replaced with the more appropriate "installation".

### Fixed
- Issue #2: the install text is now correctly detected within `.bashrc`.
- Issue #1: `bashrc.d.sh` was merged into [install.sh] as it has little purpose outside of installation and the install script calls it anyway.

## [0.3.5] - 2020-11-30
### Fixed
- In [git.bashrc]:
    - `git::specify_identity()` no longer sets identity if no matches were found.
    - Removed extraneous call of `grep "$1" <(echo "$email") > /dev/null 2>&1`.
    - After I had moved the identity reading code into its own function (`git::read_identities()`), the associative array for identities stopped working. This is because Bash cannot export associate arrays from within functions. As a workaround, the array will be saved into a file and sourced immediately after.

## [0.3.4] - 2020-11-14
### Changed
- Functions in [.bashrc.d] are now prefaced with their file name stem (e.g. `git::is_repo` from `git_is_repo`). This change was made in reference to the [Google Style Guide for Shell].
- Error statements are now sent to stderr.
- Multiple files have been modified to reduce namespace pollution:
    - Added multiple functions across multiple files to organize the modules.
    - Made other variables (like strings) into localized variables within functions.
- Unfortunately, not all of these variables could be localized. For example, `GIT_ID_FILE` in [git.bashrc] could not reasonably be declared local. Likewise, `WSL_VER` has been retained, although it may be helpful to determine WSL version without needing to use Powershell.

## [0.3.3] - 2020-10-30
### Added
- In [git.bashrc], `git_readd_origin()` is a new function that adds a repository's remote origin URL to `set-url` for simultaneous pushes. This function is a complement to `git_add_origin()`.

### Changed
- In [.bash_aliases], two existing aliases (`ll`, `la`) will use the new `lh` (equivalent to `ls -h`) for human-readable file sizes.
- Also in `.bash_aliases`, aliases are rearranged by base command.
- Furthermore, the `egrep` and `fgrep` aliases are no longer redundant (e.g. `alias egrep='egrep --color=auto'`) since `grep` is already aliased to `grep --color=auto` and the extended flags of `grep` (e.g. `-E`, for `egrep`) are recommended over the implied form (`egrep` vs `grep -E`).
- In [git.bashrc] and the case of no prior remote origin for `git_add_origin()`, the function will automatically also add the same origin to `set-url`.

### Fixed
- In [git.bashrc], variable `e` was not declared as local.

## [0.3.2] - 2020-10-25
### Added
- Added a new function in [git.bashrc] `git_add_origin` to add new origins for simultaneous pushes.

## [0.3.1] - 2020-10-20
### Changed
- Syntax is now linted with `shellcheck`.

### Fixed
- `copy_tmp()` from [_utils.bashrc] was not being loaded correctly in [install.sh]. The install script now makes sure to source the utils file.
- Switched from `whereis` to `command -v`, because `whereis` returns 0 even with nothing is found.

## [0.3.0] - 2020-10-18
### Added
- Added [wsl.bashrc] utilities for *Windows Subsystem for Linux*
- Added a way to exclude SSH key from being added to `keychain`. Create a text file in [here](.bashrc.d/keychain) named `exclusions.txt` and put one file name (not fully qualified path) per line.

### Changed
- Versioning was slightly changed, with each major addition being a subversion bump instead of fix bump. (The `y` in `x.y.z` was increased, rather than the `z`.) e.g. the change on 2020-09-04 is now `0.2.0` rather than `0.1.2`.
- [ls_colors.bashrc] was slightly rearranged so that the conditional checks for file existence (inverted from what it was), so that the smaller block is first.

## [0.2.3] - 2020-09-21
### Changed
- [keychain.bashrc] should not run under SSH sessions now.

## [0.2.2] - 2020-09-15
### Added
- Added identity management for [git.bashrc].
- Retroactively added this changelog.

## [0.2.1] - 2020-09-14
### Added
- Added `git` identity [example](.bashrc.d/git/identities/example.json).

### Changed
- Changed repo directory permission to 700 in [install.sh].
- Changed abort messages to specify which script or function was aborted.

## [0.2.0] - 2020-09-04
### Added
- Added [git.bashrc] functions, including specifying SSH key for git.

## [0.1.1] - 2020-09-02
### Added
- Added documentation.
- Added `.bashrc.d` injection script.
- Added utility functions to `.bashrc.d`.

### Changed
- Added missing handling of Anaconda's (mini)conda Python distribution.

### Fixed
- Removed `exit`s, because they exit the shell when sourced.

## [0.1.0] - 2020-09-01
### Added
- Initial version, based on my Pixelbook setup.

[Google Style Guide for Shell]: https://google.github.io/styleguide/shellguide.html
[.bash_aliases]: .bashrc.d/aliases.bashrc
[.bashrc.d]: .bashrc.d
[install.sh]: install.sh
[0.bashrc]: .bashrc.d/0.bashrc
[__new.bashrc.example]: .bashrc.d/__new.bashrc.example
[_aliases_and_vars.bashrc]: .bashrc.d/_aliases_and_vars.bashrc
[_utils.bashrc]: .bashrc.d/_utils.bashrc
[git.bashrc]: .bashrc.d/git.bashrc
[keychain.bashrc]: .bashrc.d/keychain.bashrc
[ls_colors.bashrc]: .bashrc.d/ls_colors.bashrc
[python.bashrc]: .bashrc.d/python.bashrc
[scanimage.bashrc]: .bashrc.d/scanimage.bashrc
[wsl.bashrc]: .bashrc.d/wsl.bashrc
