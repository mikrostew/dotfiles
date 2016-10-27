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

# Ember
alias jet='just ember test'
alias jets='just ember test --serve'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
#alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# functions

# change directory and list
function cdl() {
    cd "$1"
    ll
}

# set title of terminal window
function set_title() {
    echo -en "\033]0;$*\a"
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

################# GIT #########################

alias gg='git gui'
alias gr='git review'
alias gru='git review update'

# git - checkout new branch (that tracks origin/master)
function gcb() {
    # check that a branch name was passed to this function
    if [ -z "$1" ]; then
        echoerr "Come on! You have to pass a branch name for this"
        echoerr "For example:"
        echoerr "  gcb new-awesome-branch"
        return -1
    fi
    ( set -x; git checkout -b "$1" origin/master )
}

# git - rebase against master
function gram() {
    local branch_name=$(git rev-parse --abbrev-ref HEAD)
    if [ "$?" -eq 0 ]; then
        if [ "$branch_name" = "master" ]; then
            echoerr "Come on! You're already on master"
            return -1
        fi
        if [ "$(git status --porcelain --untracked-files=no)" != "" ]; then
            echoerr "Come on! You have uncommitted changes, fix that and try again"
            return -2
        fi
        ( set -x; git checkout master && git pull --rebase && git checkout "$branch_name" && git rebase master )
    fi
}

# git - show which files are different from master branch
function gfiles() {
    local branch_name=$(git rev-parse --abbrev-ref HEAD)
    if [ "$?" -eq 0 ]; then
        if [ "$branch_name" = "master" ]; then
            echoerr "Come on! You're already on master"
            return -1
        fi
        ( set -x; git diff --name-status master..$branch_name )
    fi
}


# echo to stderr instead of stdout
function echoerr() {
    echo "$@" 1>&2;
}

# git - squash commits, "rebase", merge, and submit for my LI workflow
function gsubmit() {
    # check that a commit message was passed to this function
    if [ -z "$1" ]; then
        echoerr "Come on! You have to pass in a commit message for this"
        echoerr "For example:"
        echoerr "  gsubmit \"I made some changes\""
        return -1
    fi
    # find the current branch name
    local branch_name=$(git rev-parse --abbrev-ref HEAD)
    if [ "$?" -eq 0 ]; then
        if [ "$branch_name" = "master" ]; then
            echoerr "Come on! You're already on master"
            return -1
        fi
        if [ "$(git status --porcelain --untracked-files=no)" != "" ]; then
            echoerr "Come on! You have uncommitted changes, fix that and try again"
            return -1
        fi
        # number of changes that need to be squashed
        local git_rev_list_origin=$( set -x; git rev-list --count --left-right ${branch_name}...origin/master 2>/dev/null )
        if [ "$?" -eq 0 ] && [ -n "$git_rev_list_origin" ]; then
            local git_origin_arr=($git_rev_list_origin) # will split into array because it's 2 numbers separated by spaces
            local num_commits_on_branch="${git_origin_arr[0]}"
            echo "There are ${num_commits_on_branch} commits on branch '${branch_name}'"
            # "rebase" without having to do things interactively (from Stack Overflow)
            ( set -x; git reset --soft HEAD~${num_commits_on_branch} && git commit -m "$1" )
            if [ "$?" -eq 0 ]; then
                # TODO - figure out how to recover from these
                # apply the RB to the commit
                ( set -x; git review dcommit )
                # rebase against master
                ( set -x; git pull --rebase origin master && git checkout master && git pull --rebase )
                # merge into master
                ( set -x; git merge ${branch_name} )
                # and submit
                ( set -x; git submit )
                if [ "$?" -ne 0 ]; then
                    # submit failed, could be precommit, or ACL check, or whatever
                    echoerr "Dang it! \"git submit\" failed, undoing the merge"
                    ( set -x; git reset --merge ORIG_HEAD && git checkout ${branch_name} )
                    return -1
                fi
                # rebase to pick up the change
                ( set -x; git pull --rebase )
                # and done!
            else
                # TODO what do I do if there is some error here?
                echoerr "Dang it! \"rebasing\" didn't work"
            fi
        else
            # at this point there were no changes made, so nothing to do here
            echoerr "Dang it! Couldn't figure out how many changes to squash"
        fi
    else
        # nothing to undo here, haven't done anything
        echoerr "Dang it! Couldn't figure out the current branch name"
    fi
}
