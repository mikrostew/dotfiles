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

# PATH variable for use with MacPorts
if [ -d "/opt/local/bin" ] && [ -d "/opt/local/sbin" ]; then
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi

# environment for cxxtext
if [ -d "$HOME/Dropbox/dev/includes/cxxtest-4.4/bin" ]; then
    export PATH="$PATH:$HOME/Dropbox/dev/includes/cxxtest-4.4/bin"
    export CXXTEST="$HOME/Dropbox/dev/includes/cxxtest-4.4"
fi

# bash version
echo -e "\033[1;34m bash\033[0m :"
echo "$(bash --version)"

