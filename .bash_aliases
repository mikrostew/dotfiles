# ~/.bash_aliases: contains extra aliases, sourced from .bashrc
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# platform-specific
platform=''
uname_str=$(uname)
if [ "$uname_str" == "Darwin" ]; then
    platform="Mac"
elif [ "$uname_str" == "Linux" ]; then
    platform="Linux"
fi

# color support for some commands
if [ "$platform" == "Linux" ]; then
    alias ls='ls --color=auto'
elif [ "$platform" == "Mac" ]; then
    alias ls='ls -G'
fi
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# handy aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# because I type this so much
alias x='exit'

# tmux
alias tl='tmux ls'
alias ta='tmux at'
alias tn='tmux new'

# so that tmux will display 256 colors correctly
alias tmux='TERM=xterm-256color tmux'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
#alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# functions

cdl() {
    cd "$1"
    ll
}

set_title() {
    echo -en "\033]0;$*\a"
}
