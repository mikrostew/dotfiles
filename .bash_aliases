# ~/.bash_aliases: contains extra aliases, sourced from .bashrc

# colors
source "$DOTFILES_DIR/.bash_colors"

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

# bundler
alias be='bundle exec'
alias bejb='bundle exec jekyll build'
alias bejs='bundle exec jekyll serve'
alias bi='bundle install'

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
    echo -e "${COLOR_FG_RED}$@${COLOR_RESET}" >&2
}

# echo to stdout with green text
function echoack() {
    echo -e "${COLOR_FG_GREEN}$@${COLOR_RESET}"
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

# check for minimum number of arguments to a function, and print usage if not correct
# argument(s)
# - array of expected argument names
# - number of arguments passed to function
# TODO: better way to handle this
function num_arguments_min() {
    local expected_args=( "${!1}" )
    local num_args="$2"
    local expected_num_args="${#expected_args[@]}"
    if [ "$num_args" -lt "$expected_num_args" ]
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
# Arguments:
#  1: string containing the command to display (so don't get from history)
function notify() {
    # have to do this first, before $? is changed by anything in here
    local title="Command Complete [$([ $? = 0 ] && echo "OK" || echo "ERROR!")]"
    local cmd_string="$1";
    local cmd=""
    if [ "$platform" == "Mac" ]; then
        if [ -n "$cmd_string" ]; then
            cmd="$cmd_string"
        else
            cmd="$(history | tail -n 1 | sed -e 's/^\ *[0-9]*\ *//' -e 's/[;&|]\ *notify.*$//' )"
        fi
        local sound_name="Glass" # see /System/Library/Sounds/ for list of sounds
        local script="display notification \"$cmd\" with title \"$title\" sound name \"$sound_name\""
        osascript -e "$script"
    else
        if [ -n "$cmd_string" ]; then
            cmd="$cmd_string"
        else
            cmd="$(history | tail -n 1 | sed -e 's/^\s*[0-9]\+\s*//' -e 's/[;&|]\s*notify.*$//' )"
        fi
        # because the notification body isn't shown if it contains an ampersand (see https://bugs.launchpad.net/ubuntu/+source/libnotify/+bug/1424243)
        cmd="$(echo "$cmd" | sed -e 's/[&]/&amp;/g')"
        local icon="$([ $? = 0 ] && echo terminal || echo error)"
        notify-send --urgency=low --icon="$icon" "$title" "$cmd"
    fi
}

# for long-running commands, when I forget to add a notify at the end
# hit Ctrl-Z, then use this alias to foreground the command and notify when complete
function fgn() {
  local recent_job_info="$(jobs %% 2>/dev/null)"
  if [ -n "$recent_job_info" ]; then
    local cmd="$(echo "$recent_job_info" | sed -e 's/^\[[0-9]*\].\ *[A-Za-z]*\ *//' )"
    echoack "(fg; notify '$cmd')"
    fg; notify "$cmd"
  else
    echoerr "(no background jobs running)"
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

# serve the files in the current directory
# (from https://stackoverflow.com/a/7105609)
# argument(s)
# - port (optional)
function serve_dir() {
    port="${1:-8080}"
    echo "Serving current directory on port $port"
    ruby -run -e httpd . -p $port
}

# remove any trailing newlines from the input file
# (from https://stackoverflow.com/a/12148703)
function remove_trailing_lf() {
    arguments=('<filename>')
    if num_arguments_ok arguments[@] "$#"
    then
        printf %s "$(< $1)" > $1
    fi
}

# check minimum version, and print out the result
# use this like:
# min_version_check "bash" "$(bash --version)" "4.x.x"
# min_version_check "ruby" "$RUBY_VERSION" "2.2.x" "$RUBY_ROOT"
# min_version_check "git" "$(git --version | awk '{print $3}')" "2.14.x" "$(which git)"
function min_version_check() {
    if [ -n "$4" ]; then
        path_string=" ($4)"
    else
        path_string=""
    fi
    if [ -n "$2" ]; then
        if meets_version "$2" "$3"; then
            echo -e "$1 : ${COLOR_FG_BOLD_BLUE}$2${COLOR_RESET}$path_string"
        else
            echo -e "$1 : ${COLOR_FG_RED}$2 (want >= $3)${COLOR_RESET}$path_string"
        fi
    else
        echo -e "$1 : ${COLOR_FG_RED} unknown version (want >= $3)${COLOR_RESET}"
    fi
}

# compare input semver with input constraint
# to make this easier, both must be X.X.X format
# $1 - version (semver)
# $2 - version constraint
function meets_version() {
    # parse input version
    if [[ "$1" =~ ([0-9]+)\.([0-9]+)\.([0-9]+[^ ]*) ]]; then
        input_major="${BASH_REMATCH[1]}"
        input_minor="${BASH_REMATCH[2]}"
        input_patch="${BASH_REMATCH[3]}"
    else
        echoerr "bad input version: $1"
        return 1;
    fi
    # parse input version constraint
    if [[ "$2" =~ ([0-9]+)\.([0-9]+|\*)\.([0-9]+|\*)$ ]]; then
        constraint_major="${BASH_REMATCH[1]}"
        constraint_minor="${BASH_REMATCH[2]}"
        constraint_patch="${BASH_REMATCH[3]}"
    else
        echoerr "bad version constraint: $2"
        return 1;
    fi

    # check major version
    if [ "$input_major" -gt "$constraint_major" ]; then
        return 0;
    elif [ "$input_major" -lt "$constraint_major" ]; then
        return 2;
    else
        # major versions are equal, check minor version
        if [ "$constraint_minor" = "*" ]; then
            return 0;
        elif [ "$input_minor" -gt "$constraint_minor" ]; then
            return 0;
        elif [ "$input_minor" -lt "$constraint_minor" ]; then
            return 3;
        else
            # major and minor equal, check patch version
            if [ "$constraint_patch" = "*" ]; then
                return 0;
            elif [ "$input_patch" -gt "$constraint_patch" ]; then
                return 0;
            elif [ "$input_patch" -lt "$constraint_patch" ]; then
                return 4;
            else
                # versions are equal
                return 0;
            fi
        fi
    fi
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

# kill the coproc, if it is running
# optionally pass in the name of the coproc
function kill_coproc() {
    if [ -n "$1" ]; then
        proc_pid="${1}_PID"
        [ -n "${!proc_pid}" ] && kill "${!proc_pid}"
    else
        [ -n "$COPROC_PID" ] && kill "$COPROC_PID"
    fi
}

# show xtrace output in blue
function show_blue_xtrace() {
    coproc XTRACE { BLUE="$(echo -e "\033[1;34m")"; RESET="$(echo -e "\033[0m")"; sed -e "s/.*/${BLUE}&${RESET}/"; } >&2
    exec 6>&${XTRACE[1]}
    export BASH_XTRACEFD="6"
}

# reset xtrace output to normal (stderr, default color)
function reset_xtrace() {
    kill_coproc 'XTRACE'
    unset BASH_XTRACEFD
}

# nvm
# - this slows down new tab startup, and I use it infrequently, so now it's a function
function load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    # show version
    min_version_check "node" "$(nvm current)" "1.*.*" "$NVM_BIN"
}

# git aliases and functions
[ -f "$DOTFILES_DIR/.bash_git" ] && source "$DOTFILES_DIR/.bash_git"
