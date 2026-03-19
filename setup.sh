#!/bin/bash

echo "Installing Brew"
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"' >> /home/vscode/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

brew update

echo "Installing NVIM"
brew install neovim

echo "installing fzf"
brew install fzf

echo "Installing lazygit"
brew install lazygit
