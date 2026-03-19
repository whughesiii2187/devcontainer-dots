#!/bin/bash

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

# Try a URL with $ARCH first; if it 404s, retry with x86_64.
# Usage: curl_with_arch_fallback <url-containing-$ARCH> [curl flags...]
curl_with_arch_fallback() {
  local url="$1"; shift
  local status
  status=$(curl -o /dev/null -s -w "%{http_code}" --head "$url")
  if [ "$status" = "200" ]; then
    curl "$@" "$url"
  else
    local fallback_url="${url//${ARCH}/x86_64}"
    echo "Warning: $url not found (HTTP $status), falling back to x86_64" >&2
    curl "$@" "$fallback_url"
  fi
}

### ----------------------------
### Neovim (user-scoped)
### ----------------------------

nvim_arch_dir() {
  # Returns the actual extracted dir name, preferring $ARCH then x86_64
  local base="$LOCAL_OPT/nvim-$NVIM_VERSION"
  if [ -d "$base/nvim-linux-${ARCH}" ]; then
    echo "nvim-linux-${ARCH}"
  else
    echo "nvim-linux-x86_64"
  fi
}

install_nvim() {
  local PREFIX="$LOCAL_OPT/nvim-$NVIM_VERSION"

  if [ -x "$PREFIX/bin/nvim" ]; then
    return
  fi

  echo "Installing Neovim $NVIM_VERSION ($ARCH)"
  mkdir -p "$PREFIX"
  curl_with_arch_fallback "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-${ARCH}.tar.gz" -L | tar -zxvf - -C "$PREFIX"
}

if command -v nvim >/dev/null 2>&1; then
  CURRENT="$(nvim --version | head -n1 | awk '{print $2}' | sed 's/v//')"
  if [ "$CURRENT" != "$NVIM_VERSION" ]; then
    install_nvim
    ln -sf "$LOCAL_OPT/nvim-$NVIM_VERSION/$(nvim_arch_dir)/bin/nvim" "$LOCAL_BIN/nvim"
  fi
else
  install_nvim
  ln -sf "$LOCAL_OPT/nvim-$NVIM_VERSION/$(nvim_arch_dir)/bin/nvim" "$LOCAL_BIN/nvim"
fi

### ----------------------------
### FZF
### ----------------------------
# install_fzf() {
#   if command -v fzf >/dev/null 2>&1; then
#     return
#   fi
#
#   echo "Installing FZF"
#   git clone --depth 1 https://github.com/junegunn/fzf.git "$LOCAL_OPT/fzf" 
#   "$LOCAL_OPT/fzf/install"
#   ln -sf "$LOCAL_OPT/fzf/bin/fzf" "$LOCAL_BIN/fzf"
# }
#
# install_fzf

### ----------------------------
### LazyGit
### ----------------------------
install_lazygit() {
  local PREFIX="$LOCAL_OPT/lazygit"

  if [ -x "$PREFIX" ]; then
    return
  fi

  echo "Installing Lazygit"
  mkdir -p "$PREFIX"

  curl -L "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_linux_${ARCH}.tar.gz" | tar -zxvf - -C "$PREFIX"
  ln -sf "$LOCAL_OPT/lazygit/lazygit" "$LOCAL_BIN/lazygit"
}

install_lazygit

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

### ----------------------------
### .zshrc patching
### ----------------------------
ZSHRC="$HOME/.zshrc"
DOTFILE_ALIASES="$DOTFILES_DIR/dotfiles/.zshrc"

patch_zshrc() {
  # --- 1. ZSH_DISABLE_COMPFIX (unchanged from original) ---
  if ! grep -q 'ZSH_DISABLE_COMPFIX="true"' "$ZSHRC"; then
    sed -i '/source .*oh-my-zsh.sh/i ZSH_DISABLE_COMPFIX="true"' "$ZSHRC"
  fi

  # --- 2. Add ~/.local/bin to PATH if not already present ---
  if ! grep -q 'LOCAL_BIN\|\.local/bin' "$ZSHRC"; then
    # Find the last existing export PATH line and append after it,
    # otherwise just append to end of file.
    if grep -q 'export PATH' "$ZSHRC"; then
      sed -i '/export PATH/a export PATH="$HOME/.local/bin:$PATH"' "$ZSHRC"
    else
      printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$ZSHRC"
    fi
  fi

  # --- 3. Inject aliases where the file already has its alias block ---
  # Extract only `alias` lines from the dotfile source
  local alias_lines
  alias_lines=$(grep -E '^\s*alias ' "$DOTFILE_ALIASES")

  if [ -z "$alias_lines" ]; then
    echo "No aliases found in $DOTFILE_ALIASES, skipping." >&2
    return
  fi

  # Build a sentinel so we never double-inject
  local sentinel="# --- aliases from dotfiles repo ---"
  if grep -q "$sentinel" "$ZSHRC"; then
    echo ".zshrc aliases already patched, skipping." >&2
    return
  fi

  if grep -q '^\s*alias ' "$ZSHRC"; then
    # Find the line number of the LAST existing alias line and insert after it
    local last_alias_line
    last_alias_line=$(grep -n '^\s*alias ' "$ZSHRC" | tail -1 | cut -d: -f1)
    sed -i "${last_alias_line}a\\
\\
${sentinel}" "$ZSHRC"
    # Re-read the sentinel's line number (it just moved) and append aliases below it
    local insert_at
    insert_at=$(grep -n "$sentinel" "$ZSHRC" | cut -d: -f1)
    while IFS= read -r line; do
      sed -i "${insert_at}a\\${line}" "$ZSHRC"
      (( insert_at++ ))
    done <<< "$alias_lines"
  else
    # No aliases exist yet — append a new block at the end
    {
      printf '\n%s\n' "$sentinel"
      echo "$alias_lines"
    } >> "$ZSHRC"
  fi
}

if [ -f "$ZSHRC" ]; then
  patch_zshrc
else
  ln -sfn "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
fi

echo "Dotfiles setup complete"
