#!/bin/bash

rm ~/.azure

export XDG_CONFIG_HOME="$HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

ln -sf "$PWD/nvim" "$XDG_CONFIG_HOME"/nvim
ln -sf "$PWD/.tmux.conf" "$HOME"/.tmux.conf

packages=(
  lazygit 
  tree-sitter-cli 
  fzf 
  fd
)

sudo apt update
sudo apt install npm ripgrep

for pkg in "${packages[@]}"; do
  npm install "$pkg"
done
