# Create links for dotfiles

# vim
ln -s ~/Dropbox/src/github/dotfiles/.vimrc ~/.vimrc
ln -s ~/Dropbox/src/github/dotfiles/.vim ~/.vim

# bash
ln -s ~/Dropbox/src/github/dotfiles/.bash_profile ~/.bash_profile
ln -s ~/Dropbox/src/github/dotfiles/.bashrc ~/.bashrc
ln -s ~/Dropbox/src/github/dotfiles/.bash_aliases ~/.bash_aliases

# inputrc
ln -s ~/Dropbox/src/github/dotfiles/.inputrc ~/.inputrc

# gitignore
ln -s ~/Dropbox/src/github/dotfiles/.gitignore ~/.gitignore

# then, add this to the global config
# `git config --global core.excludesfile ~/.gitignore`

# tmux
ln -s ~/Dropbox/src/github/dotfiles/.tmux.conf ~/.tmux.conf

# bundler
ln -s ~/Dropbox/src/github/dotfiles/.bundle ~/.bundle

# ssh
ln -s ~/Dropbox/src/github/dotfiles/.ssh-config ~/.ssh/config

# rubocop
ln -s ~/Dropbox/src/github/dotfiles/.rubocop.yml ~/.rubocop.yml
