#!/bin/bash

VSCODE_USER="vscode"
VSCODE_HOME="/home/$VSCODE_USER"

export XDG_CONFIG_HOME="$VSCODE_HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

apt update 
apt upgrade

add-apt-repository ppa:neovim-ppa/unstable

apt install -y neovim

cp -r "$PWD/dotfiles/nvim" "$XDG_CONFIG_HOME"/nvim
cp -r "$PWD/dotfiles/.tmux.conf" "$VSCODE_HOME"/.tmux.conf
cp -r "$PWD/dotfiles/.tmux.conf" "$VSCODE_HOME"/.tmux"

chown -R "$VSCODE_USER:$VSCODE_USER" "$VSCODE_HOME" 
