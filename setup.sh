#!/bin/bash

VSCODE_USER="vscode"
VSCODE_HOME="/home/$VSCODE_USER"
NVIMVER=0.11.4

export XDG_CONFIG_HOME="$VSCODE_HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

# sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update -y
# sudo apt install -y neovim tmux fzf ripgrep
sudo apt install -y tmux fzf ripgrep file ninja-build gettext cmake unzip curl

cd /tmp
mkdir neovim && cd neovim
curl -LO "https://github.com/neovim/neovim/archive/refs/tags/v${NVIMVER}.tar.gz"
tar xvzf "v${NVIMVER}.tar.gz"
cd "neovim-${NVIMVER}"
make CMAKE_BUILD_TYPE=RelWithDebInfo
cd build
cpack -G DEB

DEBFILE=$(ls *.deb | head -n 1)
sudo dpkg -i --force-overwrite "$DEBFILE"

sudo cp -r "$PWD/dotfiles/nvim" "$XDG_CONFIG_HOME"/nvim
sudo cp -r "$PWD/dotfiles/.tmux.conf" "$VSCODE_HOME"/.tmux.conf
sudo cp -r "$PWD/dotfiles/.tmux" "$VSCODE_HOME"/.tmux

sudo chown -R "$VSCODE_USER:$VSCODE_USER" "$VSCODE_HOME"
sudo usermod -s /usr/bin/zsh "$VSCODE_USER"

cat <<'EOF' | tee -a "$VSCODE_HOME/.zshrc" > /dev/null
alias ff='nvim "$(fzf)"'
EOF
