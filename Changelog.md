# 0.9.0 / 2017-05-28

Initial release of __homebrew-hyperkit__. This version is suitable for testing
but the TO-DO list includes:

* CI automation for stable archive packaging
* CI automation for bottle building
* CI automation for formula updates based on the above
* Potential transition out of tap to official homebrew Formula repo

In other words: there's a lot of CI work pending.

## Short list of commit messages

* Update README for v0.9.0.
* Update bottles.
* Fix install section to set version properly when building a bottle.
* Refactor strip_heredoc() to satisfy brew audit and remain functional.
* Fixes for brew audit (rubocop lint prefs).
* Refactor test to download kernel as a resource.
* Initial commit.
