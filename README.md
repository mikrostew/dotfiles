# Config files for the computers I use

## Installing these on a new machine

First, transfer my SSH setup (keys and authorization) to the new machine

```
$ ssh user@host "mkdir -p /home/<user>/.ssh/"
$ scp ~/.ssh/authorized_keys user@host:/home/<user>/.ssh/
$ scp ~/.ssh/github_rsa user@host:/home/<user>/.ssh/
```

On that machine, clone this repo over SSH

```
$ ssh-agent bash -c 'ssh-add /home/<user>/.ssh/github_rsa; git clone git@github.com:mikrostew/dotfiles.git'
```

Then run the script to make the links to all these files

```
$ cd src/gh/dotfiles/
$ ./make-dotfile-links "$HOME/src/gh/dotfiles"
```

Setup other stuff

chruby
```
git clone git@github.com:postmodern/chruby.git
cd chruby/
sudo ./scripts/setup.sh
```

ruby-install
```
git clone git@github.com:postmodern/ruby-install.git
cd ruby-install/
sudo ./setup.sh
```

TODO: look at https://dotfiles.github.io/, check out things there
