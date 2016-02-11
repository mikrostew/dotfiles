# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# if not interactive, return (if flags do not contain "i")
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# prompt string:
# replace home dir in PWD with ~,
# add a trailing slash to the PWD if there is not one
MY_PWD='$(echo "$PWD" | sed -e "s|^$HOME|~|" -e "s|/*$|/|")'
# git / svn status
if [ -f "$HOME/Dropbox/src/github/repo-status-bash/.bash_repo_status" ]; then
    source "$HOME/Dropbox/src/github/repo-status-bash/.bash_repo_status"
    PS1='\n(\t) \033[1;30m\u\033[0m@\033[1;30m\h\033[0m:\033[1;30m$(eval "echo ${MY_PWD}")\033[0m$(repo_status)\n\$ '
else
    PS1='\n(\t) \033[1;30m\u\033[0m@\033[1;30m\h\033[0m:\033[1;30m$(eval "echo ${MY_PWD}")\033[0m\n\$ '
fi

# If this is an xterm set the title to user@host:dir
# (this will overwrite the terminal title after every command - don't want that)
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# formatting for `ri` documentation
export RI="-T --format=ansi"

# chruby
if [ -f "/usr/local/share/chruby/chruby.sh" ]; then
    source /usr/local/share/chruby/chruby.sh
    chruby ruby-2
    echo -e "\033[1;31m chruby\033[0m : using \033[1;31m$RUBY_VERSION\033[0m from $RUBY_ROOT"
else
    echo -e "\033[1;31m chruby\033[0m : not installed"
fi

# 256 color support
export TERM=xterm-256color

