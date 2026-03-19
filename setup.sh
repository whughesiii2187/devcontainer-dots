#!/bin/bash

echo "Installing Brew"
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
brew update

echo "Installing NVIM"
brew install neovim

echo "installing fzf"
brew install fzf

echo "Installing lazygit"
brew install lazygit
