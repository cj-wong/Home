# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.3.3] - 2020-10-30
### Added
- In [git.bashrc](.bashrc.d/git.bashrc), `git_readd_origin()` is a new function that adds a repository's remote origin URL to `set-url` for simultaneous pushes. This function is a complement to `git_add_origin()`.

### Changed
- In [.bash_aliases](.bash_aliases), two existing aliases (`ll`, `la`) will use the new `lh` (equivalent to `ls -h`) for human-readable file sizes.
- Also in `.bash_aliases`, aliases are rearranged by base command.
- Furthermore, the `egrep` and `fgrep` aliases are no longer redundant (e.g. `alias egrep='egrep --color=auto'`) since `grep` is already aliased to `grep --color=auto` and the extended flags of `grep` (e.g. `-E`, for `egrep`) are recommended over the implied form (`egrep` vs `grep -E`).
- In [git.bashrc](.bashrc.d/git.bashrc) and the case of no prior remote origin for `git_add_origin()`, the function will automatically also add the same origin to `set-url`.

### Fixed
- In [git.bashrc](.bashrc.d/git.bashrc), variable `e` was not declared as local.

## [0.3.2] - 2020-10-25
### Added
- Added a new function in [git.bashrc](.bashrc.d/git.bashrc) `git_add_origin` to add new origins for simultaneous pushes.

## [0.3.1] - 2020-10-20
### Changed
- Syntax is now linted with `shellcheck`.

### Fixed
- `copy_tmp()` from [utils.bashrc](.bashrc.d/utils.bashrc) was not being loaded correctly in [install.sh](install.sh). The install script now makes sure to source the utils file.
- Switched from `whereis` to `command -v`, because `whereis` returns 0 even with nothing is found.

## [0.3.0] - 2020-10-18
### Added
- Added [Windows Subsystem for Linux](.bashrc.d/wsl.bashrc) utilities
- Added a way to exclude SSH key from being added to `keychain`. Create a text file in [here](.bashrc.d/keychain) named `exclusions.txt` and put one file name (not fully qualified path) per line.

### Changed
- Versioning was slightly changed, with each major addition being a subversion bump instead of fix bump. (The `y` in `x.y.z` was increased, rather than the `z`.) e.g. the change on 2020-09-04 is now `0.2.0` rather than `0.1.2`.
- [ls_colors.bashrc](.bashrc.d/ls_colors.bashrc) was slightly rearranged so that the conditional checks for file existence (inverted from what it was), so that the smaller block is first.

## [0.2.3] - 2020-09-21
### Changed
- `keychain` should not run under SSH sessions now

## [0.2.2] - 2020-09-15
### Added
- Added `git` identity management [functions](.bashrc.d/git.bashrc)
- Retroactively added this changelog

## [0.2.1] - 2020-09-14
### Added
- Added `git` identity [example](.bashrc.d/git/identities/example.json)

### Changed
- Changed repo directory permission to 700 in [install](install.sh)
- Changed abort messages to specify which script or function was aborted

## [0.2.0] - 2020-09-04
### Added
- Added [.bashrc.d](.bashrc.d/git.bashrc) functions for `git`, including specifying SSH key for git

## [0.1.1] - 2020-09-02
### Added
- Added documentation
- Added `.bashrc.d` injection script
- Added utility functions to `.bashrc.d`

### Changed
- Added missing handling of Anaconda's (mini)conda Python distribution

### Fixed
- `exit`s removed, because they exit the shell

## [0.1.0] - 2020-09-01
### Added
- Initial version, based on my Pixelbook setup