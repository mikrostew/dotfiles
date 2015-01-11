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
MY_PS='$(echo "$PWD" | sed -e "s|^$HOME|~|" -e "s|/*$|/|")'
# show what kind of repo we're in
# - some code from http://zanshin.net/2012/03/09/wordy-nerdy-zsh-prompt/
# - and https://github.com/sjl/oh-my-zsh/commit/3d22ee248c6bce357c018a93d31f8d292d2cb4cd
# - and http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array
repo_status() {
    git_status=$(git status 2>/dev/null)
    if [ $? -eq 0 ]; then
        branch=$( ( [[ "$git_status" =~ On\ branch\ ([^$'\n']*) ]] && echo ${BASH_REMATCH[1]} ) || echo '?' )
        staged=$( [[ "$git_status" =~ "Changes to be committed" ]] && echo 'stag' )
        unstaged=$( [[ "$git_status" =~ "Changes not staged for commit" ]] && echo 'unst' )
        untracked=$( [[ "$git_status" =~ "Untracked files" ]] && echo 'untr' )
        ok=$( [[ "$git_status" =~ "working directory clean" ]] && echo 'ok' )
        stat_str=($staged $unstaged $untracked $ok)
        stat_str=$(IFS=, ; echo "${stat_str[*]}")
        echo " [git/${branch} ${stat_str}]"
        return
    fi
    svn info >/dev/null 2>&1 && echo ' [svn]' && return
    echo ''
}
PS1='\n(\t) \u@\h[\#] $(eval "echo ${MY_PS}")$(repo_status)\n\$ '

# If this is an xterm set the title to user@host:dir
# (this will overwrite the terminal title after every command - don't want that)
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

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

# output fortune at every login
if [ -f "/opt/local/bin/fortune" ]; then
    # Mac
    /opt/local/bin/fortune
elif [ -f "/usr/games/fortune" ]; then
    # Ubuntu
    /usr/games/fortune
else
    echo "(fortune not installed)"
fi

# formatting for `ri` documentation
export RI="-T --format=ansi"

# rbenv
#export PATH="$HOME/.rbenv/bin:$PATH"
#eval "$(rbenv init -)"
