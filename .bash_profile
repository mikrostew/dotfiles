# ~/.bash_profile: executed by the command interpreter for login shells.

# if running bash, include .bashrc if it exists
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# other bash_profile things (on work machine)
[ -f "$HOME/.bash_profile-local" ] && . "$HOME/.bash_profile-local"

# for homebrew I think?
export PATH="/usr/local/sbin:$PATH"

# for bash-completion after upgrading to bash 4.x with homebrew
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# set secrets as environment vars, so I don't commit them to repos :)
[ -f "$HOME/Dropbox/secret/set-env.sh" ] && . "$HOME/Dropbox/secret/set-env.sh"

