#!/bin/bash

rm ~/.azure

export XDG_CONFIG_HOME="$HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

cp -r "$PWD/dotfiles/nvim" "$XDG_CONFIG_HOME"/nvim
cp -r "$PWD/dotfiles/.tmux.conf" "$HOME"/.tmux.conf
