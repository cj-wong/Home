# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
