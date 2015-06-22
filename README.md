# Config files used on my development machines

I use these config files on all of my development machines, at work and home. I put this repository in Dropbox, and sync all of the machines to that. These commands work on Linux and Mac. I have not used these at all on Windows.

## vim

`ln -s Dropbox/dev/conf/.vimrc ~/.vimrc`
`ln -s ~/Dropbox/dev/plugin/.vim ~/.vim`

## bash

`ln -s Dropbox/dev/conf/.bash_profile ~/.bash_profile`

`ln -s Dropbox/dev/conf/.bashrc ~/.bashrc`

`ln -s Dropbox/dev/conf/.bash_aliases ~/.bash_aliases`

## inputrc

`ln -s Dropbox/dev/conf/.inputrc ~/.inputrc`

## gitignore

`ln -s Dropbox/dev/conf/.gitignore ~/.gitignore`

then, add this to the global config
`git config --global core.excludesfile ~/.gitignore`

## tmux

`ln -s ~/Dropbox/dev/conf/.tmux.conf ~/.tmux.conf`

## bundler

`ln -s ~/Dropbox/dev/conf/.bundle ~/.bundle`

## fortune

### Mac

First install MacPorts (https://www.macports.org/install.php)
Then `sudo port install fortune`

### Ubuntu

`sudo apt-get install fortune`

## ssh

`ln -s ~/Dropbox/dev/conf/.ssh-config ~/.ssh/config`

