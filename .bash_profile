# ~/.bash_profile: executed by the command interpreter for login shells.

# if running bash, include .bashrc if it exists
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# other bash_profile things (on work machine)
[ -f "$HOME/.bash_profile-local" ] && . "$HOME/.bash_profile-local"

# for homebrew I think?
export PATH="/usr/local/sbin:$PATH"

# for bash-completion after upgrading to bash 4.x with homebrew
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# path for PostgreSQL on OSX
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin

# for using Jekyll with Github pages - DO NOT COMMIT THIS!!!
export JEKYLL_GITHUB_TOKEN=d2462529e7083a6e5a23cd115e9c7e9a75f4afd0

