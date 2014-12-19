# ~/.bash_aliases: contains extra aliases, sourced from .bashrc
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

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
