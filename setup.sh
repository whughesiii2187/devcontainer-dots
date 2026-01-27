#!/bin/bash

VSCODE_USER="vscode"
VSCODE_HOME="/home/$VSCODE_USER"

export XDG_CONFIG_HOME="$VSCODE_HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

apt update -y
apt upgrade -y

add-apt-repository ppa:neovim-ppa/unstable -y

apt install -y neovim tmux fzf ripgrep

cp -r "$PWD/dotfiles/nvim" "$XDG_CONFIG_HOME"/nvim
cp -r "$PWD/dotfiles/.tmux.conf" "$VSCODE_HOME"/.tmux.conf
cp -r "$PWD/dotfiles/.tmux" "$VSCODE_HOME"/.tmux

chown -R "$VSCODE_USER:$VSCODE_USER" "$VSCODE_HOME"

echo "alias ff='nvim "$(fzf)"'" >> "VSCODE_HOME"/.zshrc
usermod -s /usr/bin/zsh "$VSCODE_USER"
