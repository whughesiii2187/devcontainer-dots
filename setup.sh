#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "Installing Brew"
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

brew update

echo "Installing packages"
brew install neovim fzf lazygit zsh tmux copilot

### ----------------------------
### Dotfiles
### ----------------------------
echo "Applying dotfiles"

if [ -f "$HOME/.oh-my-zsh" ]; then
  rm -rf "$HOME/.oh-my-zsh"
fi

ln -sfn "$DOTFILES_DIR/dotfiles/.config/nvim" "$XDG_CONFIG_HOME/nvim"
ln -sfn "$DOTFILES_DIR/dotfiles/.oh-my-zsh" "$HOME/.oh-my-zsh"
ln -sfn "$DOTFILES_DIR/dotfiles/.tmux" "$HOME/.tmux"
ln -sfn "$DOTFILES_DIR/dotfiles/.tmux.conf" "$HOME/.tmux.conf"

ZSHRC="$HOME/.zshrc"
DOTFILE_ALIASES="$DOTFILES_DIR/dotfiles/.zshrc"

if [ -f "$ZSHRC" ]; then
  echo "source $DOTFILES_DIR/dotfiles/.zshrc" >> "$HOME/.zshrc"
else
  ln -sfn "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
fi

echo "Dotfiles setup complete"
