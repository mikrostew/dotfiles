# ~/.bash_profile: executed by the command interpreter for login shells.

# if running bash, include .bashrc if it exists
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# some installers like to add things to this file, so prevent that stuff from running
return 0
export VOLTA_HOME="/Users/mistewar/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
