#!/bin/bash

mkdir -p -m 700 .ssh

if [[ $1 == 'macos' ]]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  brew update && brew upgrade
  brew install bundle && brew bundle --file ~/dotfiles/tools/Brewfile
  brew cleanup && brew cleanup -s

  ln ~/dotfiles/.$1.zprofile ~/.zprofile
  ln ~/dotfiles/.ssh/$1.config ~/.ssh/config
fi

ln ~/dotfiles/.$1.zshrc ~/.zshrc
ln ~/dotfiles/.gitconfig ~/.gitconfig
ln ~/dotfiles/.hushlogin ~/.hushlogin

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

if [[ $1 == 'linux' ]]; then
  sudo chsh -s $(which zsh) $(whoami) && zsh
else
  source ~/.zshrc
fi
