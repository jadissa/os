#!/bin/bash
# Software Update Tool - automatically find and install macOS software from Apple
softwareupdate --all --install --force

# Check your system for potential problems. Will exit with a non-zero status if any potential problems are found
brew doctor --verbose

# Fetch the newest version of Homebrew and all formulae from GitHub using git(1) and perform any necessary migrations
brew update --verbose

# Automatically upgrade your installed formulae. If the Caskroom exists locally Casks will be upgraded as well. Must be passed with start
brew upgrade --verbose