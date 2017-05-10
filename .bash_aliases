# ~/.bash_aliases: contains extra aliases, sourced from .bashrc
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# platform-specific
platform=''
uname_str=$(uname)
if [ "$uname_str" == "Darwin" ]; then
    platform="Mac"
elif [ "$uname_str" == "Linux" ]; then
    # Linux desktop and termux on Android
    platform="Linux"
fi

# color support for some commands
if [ "$platform" == "Linux" ]; then
    alias ls='ls --color=auto'
elif [ "$platform" == "Mac" ]; then
    alias ls='ls -G'
fi

# --color not supported for grep on Android
if [ "$(grep --version 2>/dev/null)" -a $? = 0 ]; then
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

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

# Ember
alias jet='just ember test'
alias jets='just ember test --serve'

# BashRC
alias rebash='source $HOME/.bashrc'

# show the TODOs I have left in the code (outputs the lines in each file to /dev/tty)
# TODO make this into a function so I can pass in a directory
alias todo='( set -x; grep --color=always -nr --exclude-dir bower_components --exclude-dir node_modules "TODO" . | tee /dev/tty | wc -l )'

# show running processes in OSX, sorted by CPU usage
alias cpu='top -F -R -o cpu'

# remove trailing newline from a file
alias rmlf='perl -pi -e "chomp if eof"'


# shared functions

# echo to stderr with red text
function echoerr() {
    COLOR_RED='\033[0;31m'
    COLOR_RESET='\033[0m'
    echo -e "${COLOR_RED}$@${COLOR_RESET}" 1>&2
}

# echo to stdout with green text
function echoack() {
    COLOR_GREEN='\033[0;32m'
    COLOR_RESET='\033[0m'
    echo -e "${COLOR_GREEN}$@${COLOR_RESET}"
}

# check for exact number of arguments to a function, and print usage if not correct
# argument(s)
# - array of expected argument names
# - number of arguments passed to function
function num_arguments_ok() {
    local expected_args=( "${!1}" )
    local num_args="$2"
    local expected_num_args="${#expected_args[@]}"
    if [ "$expected_num_args" -ne "$num_args" ]
    then
        # $FUNCNAME is an array of the current call stack
        echoerr "Come on! This is how to use this:"
        echoerr ""
        echoerr "  ${FUNCNAME[1]} ${expected_args[*]}"
        return -1
    fi
    return 0
}


# other functions

# show a desktop notification with sound after a long-running command
# Usage:
#   sleep 10; notify
function notify() {
    local title="Command Complete [$([ $? = 0 ] && echo "OK" || echo "ERROR!")]"
    if [ "$platform" == "Mac" ]; then
        local cmd="$(history | tail -n1 | sed -e 's/^\ *[0-9]*\ *//' -e 's/[;&|]\ *notify$//')"
        local sound_name="Glass" # see /System/Library/Sounds/ for list of sounds
        local script="display notification \"$cmd\" with title \"$title\" sound name \"$sound_name\""
        osascript -e "$script"
    else
        local body="$(history | tail -n1 | sed -e 's/^\s*[0-9]\+\s*//' -e 's/[;&|]\s*notify$//')"
        local icon="$([ $? = 0 ] && echo terminal || echo error)"
        notify-send --urgency=low --icon="$icon" "$title" "$body"
    fi
}

# update the dotfiles repo and source .bashrc
function updot() {
    ( set +e; set -x; pushd "$DOTFILES_DIR"; git pull --rebase; popd; )
    source "$HOME/.bashrc"
}

# change directory and list
function cdl() {
    cd "$1"
    ll
}

# set title of terminal window
function set_title() {
    echo -en "\033]0;$*\a"
}

# set secrets as environment vars, so I don't commit them to repos :)
function set_env() {
    [ -f "$HOME/Dropbox/secret/set-env.sh" ] && . "$HOME/Dropbox/secret/set-env.sh"
}


function _convert_to_bytes() {
    # convert from input like "4.0K" to "4096"
    suffix="${1: -1}"
    numbers="${1%$suffix}"
    case $suffix in
    "K")
        multiplier=1024
        ;;
    "M")
        multiplier=$((1024*1024))
        ;;
    "G")
        multiplier=$((1024*1024*1024))
        ;;
    "0")
        multiplier=0
        numbers=0
        ;;
    *)
        multiplier=1
        ;;
    esac
    bytes=$(printf "%.0f" $(echo "$numbers * $multiplier" | bc))
    #echo "$1:$numbers:$suffix:$multiplier:$bytes"
    echo "$bytes"
}

function _print_object_info() {
    # arguments
    # $1 - file/dir name
    # $2 - size (human-readable)
    # $3 - indentation
    # TODO: colored output
    if [ "$3" -ge 0 ]; then
        counter=0
        while [ "$counter" -lt "$3" ]; do
            echo -n " "
            counter=$((counter+1))
        done
        echo -n "└ "
    fi
    if [ -d "$1" ]; then
        trailing_slash="/"
    else
        trailing_slash=""
    fi
    short_name=${1##*/}
    echo "$short_name$trailing_slash ($2)"
}

# find big files and directories (useful when disk is getting full)
function bigfiles() {
    # arguments
    # $1 - directory to traverse
    if [ -z "$1" ]; then
        base_dir="."
    else
        base_dir="$1"
    fi
    current_dir=$(GLOBIGNORE=.:..; du -shx $1 )
    #echo "$current_dir"
    linearray=($current_dir)
    bytes=$(_convert_to_bytes "${linearray[0]}")
    _print_object_info "${linearray[1]}" "${linearray[0]}" -1

    _bigfiles_helper "$base_dir" 0
}

function _bigfiles_helper() {
    # arguments
    # $1 - directory name
    # $2 - indentation
    local toplevel=$(GLOBIGNORE=.:..; du -shx $1/* 2>/dev/null )
    local first_largest_bytes=0
    local second_largest_bytes=0
    first_largest_name=""
    second_largest_name=""
    #local num_objects=0 # number of files and directories found
    if [ ! -z "$toplevel" ]; then
        while read -r line; do
            #num_objects=$((num_objects+1))
            # these lines look like "4.0K .bash_aliases"
            # split it into the size and the file/dir name"
            #echo "$line"
            local linearray=($line)
            local bytes=$(_convert_to_bytes "${linearray[0]}")
            if [ "$bytes" -gt "$first_largest_bytes" ]; then
                second_largest_bytes="$first_largest_bytes"
                second_largest_human_readable="$first_largest_human_readable"
                second_largest_name="$first_largest_name"
                first_largest_bytes="$bytes"
                first_largest_human_readable="${linearray[0]}"
                first_largest_name="${linearray[1]}"
            elif [ "$bytes" -gt "$second_largest_bytes" ]; then
                second_largest_bytes="$bytes"
                second_largest_human_readable="${linearray[0]}"
                second_largest_name="${linearray[1]}"
            fi
        done <<< "$toplevel"

        # TODO: only recurse if size is at least 20% of parent (configurable?)
        if [ ! -z "$first_largest_name" ]; then
            _print_object_info "$first_largest_name" "$first_largest_human_readable" "$2"
            local next_dir="$first_largest_name"
            if [ -d "$next_dir" ]; then
                #_bigfiles_helper "$next_dir" "$(($2+3))"
                echo "$(_bigfiles_helper $next_dir $(($2+3)))"
            fi
        fi

        if [ ! -z "$second_largest_name" ]; then
            _print_object_info "$second_largest_name" "$second_largest_human_readable" "$2"
            next_dir="$second_largest_name"
            if [ -d "$next_dir" ]; then
                #_bigfiles_helper "$next_dir" "$(($2+3))"
                echo "$(_bigfiles_helper $next_dir $(($2+3)))"
            fi
        fi
    fi
}

# git aliases and functions
[ -f "$DOTFILES_DIR/.bash_git" ] && source "$DOTFILES_DIR/.bash_git"

