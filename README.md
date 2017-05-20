# Config files for the computers I use

## Installing these on a new machine

First, transfer my Github RSA key to the new machine

`$ scp ~/.ssh/github_rsa user@host:/home/user/.ssh/`

On that machine, clone this repo over SSH

`$ ssh-agent bash -c 'ssh-add /home/user/.ssh/github_rsa; git clone git@github.com:mikrostew/dotfiles.git'`

Then run the script to make the links to all these files

`$ cd dotfiles/`  
`$ ./makelinks.sh`

