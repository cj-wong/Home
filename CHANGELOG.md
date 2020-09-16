# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.1.4] - 2020-09-15
### Added
- Added `git` identity management [functions](.bashrc.d/git.bashrc)
- Retroactively added this changelog

## [0.1.3] - 2020-09-14
### Added
- Added `git` identity [example](.bashrc.d/git/identities/example.json)

### Changed
- Changed repo directory permission to 700 in [install](install.sh)
- Changed abort messages to specify which script or function was aborted

## [0.1.2] - 2020-09-04
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
