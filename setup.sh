#!/bin/sh

### ----------------------------
### Config
### ----------------------------
NVIM_VERSION="0.11.4"
LG_VERSION="0.59.0"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$LOCAL_BIN" "$LOCAL_OPT" "$XDG_CONFIG_HOME"
export PATH="$LOCAL_BIN:$PATH"

### ----------------------------
### Helpers
### ----------------------------
arch() {
  case "$(uname -m)" in
    x86_64) echo amd64 ;;
    aarch64|arm64) echo arm64 ;;
    *) echo "Unsupported architecture" && exit 1 ;;
  esac
}

ARCH="$(arch)"

### ----------------------------
### Neovim (user-scoped)
### ----------------------------
install_nvim() {
  local PREFIX="$LOCAL_OPT/nvim-$NVIM_VERSION"

  if [ -x "$PREFIX/bin/nvim" ]; then
    return
  fi

  echo "Installing Neovim $NVIM_VERSION ($ARCH)"
  mkdir -p "$PREFIX"
  curl -L "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-${ARCH}.tar.gz" | tar -zxvf - -C "$PREFIX"
}

if command -v nvim >/dev/null 2>&1; then
  CURRENT="$(nvim --version | head -n1 | awk '{print $2}' | sed 's/v//')"
  if [ "$CURRENT" != "$NVIM_VERSION" ]; then
    install_nvim
    ln -sf "$LOCAL_OPT/nvim-$NVIM_VERSION/nvim-linux-${ARCH}/bin/nvim" "$LOCAL_BIN/nvim"
  fi
else
  install_nvim
  ln -sf "$LOCAL_OPT/nvim-$NVIM_VERSION/nvim-linux-${ARCH}/bin/nvim" "$LOCAL_BIN/nvim"
fi

### ----------------------------
### OhMyPosh
### ----------------------------
echo "Installing OhMyPosh"
curl -L https://ohmyposh.dev/install.sh | bash -s

### ----------------------------
### LazyGit
### ----------------------------
mkdir -p "$PREFIX/lazygit"
echo "Installing Lazygit"
curl -L "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_linux_${ARCH}.tar.gz" | tar -zxvf - -C "$PREFIX/lazygit"

ln -sf "$LOCAL_OPT/lazygit/lazygit" "$LOCAL_BIN/lazygit"
### ----------------------------
### Dotfiles
### ----------------------------
echo "Applying dotfiles"

ln -sfn "$DOTFILES_DIR/dotfiles/.config/nvim" "$XDG_CONFIG_HOME/nvim"
ln -sfn "$DOTFILES_DIR/dotfiles/.config/ohmyposh" "$XDG_CONFIG_HOME/ohmyposh"
ln -sfn "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
ln -sfn "$DOTFILES_DIR/dotfiles/.oh-my-zsh" "$HOME/.oh-my-zsh"

echo "Dotfiles setup complete"

