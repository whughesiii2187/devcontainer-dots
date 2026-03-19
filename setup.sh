#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

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

echo "Installing ZSH"
brew install zsh

echo "Installing TMUX"
brew install tmux

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
ln -sfn "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc"

### ----------------------------
### .zshrc patching
### ----------------------------
# ZSHRC="$HOME/.zshrc"
# DOTFILE_ALIASES="$DOTFILES_DIR/dotfiles/.zshrc"
#
# patch_zshrc() {
#   ## Disable Compfix
#   if ! grep -q 'ZSH_DISABLE_COMPFIX="true"' "$ZSHRC"; then
#     sed -i '/source .*oh-my-zsh.sh/i ZSH_DISABLE_COMPFIX="true"' "$ZSHRC"
#   fi
#
#   # Inject aliases where the file already has its alias block ---
#   # Extract only `alias` lines from the dotfile source
#   local alias_lines
#   alias_lines=$(grep -E '^\s*alias ' "$DOTFILE_ALIASES")
#
#   if [ -z "$alias_lines" ]; then
#     echo "No aliases found in $DOTFILE_ALIASES, skipping." >&2
#     return
#   fi
#
#   # Build a sentinel so we never double-inject
#   local sentinel="# --- aliases from dotfiles repo ---"
#   if grep -q "$sentinel" "$ZSHRC"; then
#     echo ".zshrc aliases already patched, skipping." >&2
#     return
#   fi
#
#   if grep -q '^\s*alias ' "$ZSHRC"; then
#     # Find the line number of the LAST existing alias line and insert after it
#     local last_alias_line
#     last_alias_line=$(grep -n '^\s*alias ' "$ZSHRC" | tail -1 | cut -d: -f1)
#     sed -i "${last_alias_line}a\\
# \\
# ${sentinel}" "$ZSHRC"
#     # Re-read the sentinel's line number (it just moved) and append aliases below it
#     local insert_at
#     insert_at=$(grep -n "$sentinel" "$ZSHRC" | cut -d: -f1)
#     while IFS= read -r line; do
#       sed -i "${insert_at}a\\${line}" "$ZSHRC"
#       (( insert_at++ ))
#     done <<< "$alias_lines"
#   else
#     # No aliases exist yet — append a new block at the end
#     {
#       printf '\n%s\n' "$sentinel"
#       echo "$alias_lines"
#     } >> "$ZSHRC"
#   fi
# }
#
# if [ -f "$ZSHRC" ]; then
#   patch_zshrc
# else
  # ln -sfn "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
# fi

echo "Dotfiles setup complete"
