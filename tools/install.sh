#!/bin/sh

mkdir -p -m 700 .ssh

test -e ~/.profile && rm ~/.profile
test -e ~/.bash_logout && rm ~/.bash_logout
test -e ~/.bashrc && rm ~/.bashrc
test -e ~/.cloud-locale-test.skip && rm ~/.cloud-locale-test.skip

ln ~/dotfiles/.zshrc ~/.zshrc
ln ~/dotfiles/.gitconfig ~/.gitconfig
ln ~/dotfiles/.hushlogin ~/.hushlogin

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sudo chsh -s $(which zsh) $(whoami) && zsh
