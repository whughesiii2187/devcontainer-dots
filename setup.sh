#!/bin/bash

rm ~/.azure

export XDG_CONFIG_HOME="$HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

cp "$PWD/dotfiles/nvim" "$XDG_CONFIG_HOME"/nvim
cp "$PWD/dotfiles/.tmux.conf" "$HOME"/.tmux.conf
