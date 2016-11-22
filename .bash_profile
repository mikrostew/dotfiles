# ~/.bash_profile: executed by the command interpreter for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# other bash_profile things (when on work machine)
if [ -f "$HOME/.bash_profile-local" ]; then
    . "$HOME/.bash_profile-local"
fi

# PATH variable for use with MacPorts
if [ -d "/opt/local/bin" ] && [ -d "/opt/local/sbin" ]; then
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi

# environment for cxxtext
if [ -d "$HOME/Dropbox/dev/includes/cxxtest-4.4/bin" ]; then
    export PATH="$PATH:$HOME/Dropbox/dev/includes/cxxtest-4.4/bin"
    export CXXTEST="$HOME/Dropbox/dev/includes/cxxtest-4.4"
fi

export PATH="/usr/local/sbin:$PATH"
