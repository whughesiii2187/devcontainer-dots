# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
plugins=(
  git
  kubectl
  helm
)


# User configuration
zstyle ':completion:*' use-cache no
export ZSH_DISABLE_COMPFIX=true
ZSH_THEME="bureau"
source $ZSH/oh-my-zsh.sh

alias vi="nvim"
alias v="nvim"
alias vim="nvim"
alias getmyip="dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com"
alias python="python3"
alias genpass="~/scripts/python/randomgen.py"
alias gg="lazygit"
alias ff='nvim "$(fzf)"'
alias acr="az login && az acr login -n r1k8sacrdev"

