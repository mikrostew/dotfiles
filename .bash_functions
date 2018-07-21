#!/usr/bin/env bash
# $DOTFILES_DIR/.bash_functions: contains extra functions, sourced from .bashrc

require "$DOTFILES_DIR/.bash_colors"
require "$DOTFILES_DIR/.bash_shared_functions"

# other functions

# show running processes, sorted by CPU usage
cpu() {
  if platform_is_mac; then
    do_cmd top -F -R -o cpu
  else
    do_cmd top -o +%CPU
  fi
}

# show a desktop notification with sound after a long-running command
# Usage:
#   sleep 10; notify
# Arguments:
#  1: string containing the command to display (so don't get from history)
# NOTE: this must be a function, because history doesn't work for a script
notify() {
  # have to do this first, before $? is changed by anything in here
  local title="Command Complete [$([ $? = 0 ] && echo "OK" || echo "ERROR!")]"
  local cmd_string="$1";
  local cmd=""
  if platform_is_mac; then
    if [ -n "$cmd_string" ]; then
      cmd="$cmd_string"
    else
      cmd="$(history | tail -n 1 | sed -e 's/^\ *[0-9]*\ *//' -e 's/[;&|]\ *notify.*$//' )"
    fi
    local sound_name="Glass" # see /System/Library/Sounds/ for list of sounds
    local script="display notification \"$cmd\" with title \"$title\" sound name \"$sound_name\""
    osascript -e "$script"
  else # Linux
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
fgn() {
  local recent_job_info="$(jobs %% 2>/dev/null)"
  if [ -n "$recent_job_info" ]; then
    local cmd="$(echo "$recent_job_info" | sed -e 's/^\[[0-9]*\].\ *[A-Za-z]*\ *//' )"
    echo_ack "(fg; notify '$cmd')"
    fg; notify "$cmd"
  else
    echo_err "(no background jobs running)"
  fi
}

# update the dotfiles repo and source .bashrc
updot() {
  ( set +e; set -x; pushd "$DOTFILES_DIR"; git pull --rebase; popd; )
  unalias -a
  source "$HOME/.bashrc"
}

# change directory and list
cdl() {
  cd "$1"
  ll
}

# set title of terminal window
set_title() {
  echo -en "\033]0;$*\a"
}

# set secrets as environment vars, so I don't commit them to repos :)
set_env() {
  echo_dep "use get-api-token instead of set-env"
  [ -f "$HOME/Dropbox/secret/set-env.sh" ] && . "$HOME/Dropbox/secret/set-env.sh"
}

# remove any trailing newlines from the input file
# (from https://stackoverflow.com/a/12148703)
rmlf() {
  arguments=('<filename>')
  if num_arguments_ok arguments[@] "$#"
  then
    printf %s "$(< $1)" > $1
  fi
}

# TODO: split this and it's associated functions to a separate file in scripts/
# check minimum version, and print out the result
# Arguments:
# $1 - program/command/language name
# $2 - acceptable version range (semver)
# $3 - how to get the version of this (NOTE: will be eval-ed)
# $4 - command to install this
# $5 - [optional] path to where this is installed, instead of using `which` (NOTE: will be eval-ed)
min_version_check() {
  # 1) check if this is installed
  if [ -n "$5" ]; then
    install_path=$(eval "$5")
  else
    install_path=$(which "$1")
  fi
  if [ -z "$install_path" ]; then
    echo -e "$1 : ${COLOR_FG_RED}not installed (want $2), install with '${4:-(unknown command)}'${COLOR_RESET}"
    return 1
  fi
  # 2) check the minimum version
  current_version=$(eval "$3")
  if [ -n "$current_version" ]; then
    if meets_version "$(normalize_version $current_version)" "$2"; then
      # don't print anything for this
      return
    else
      echo -e "$1 : ${COLOR_FG_RED}found $current_version (want $2)${COLOR_RESET} ($install_path)"
    fi
  else
    echo -e "$1 : ${COLOR_FG_RED}unknown version (want $2)${COLOR_RESET} ($install_path)"
  fi
  return 1 # if it hasn't already returned, it didn't meet the version
}

# convert versions to X.X.X format
normalize_version() {
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "$1.0.0"
  elif [[ "$1" =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "$1.0"
  elif [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    # there may be some junk after the version (looking at you bash), get rid of that
    echo "$BASH_REMATCH"
  else
    echo "$1"
  fi
}

# compare input semver with input constraint
# (using semver from NPM for this - https://github.com/npm/node-semver)
# $1 - program version (semver format)
# $2 - version range (semver format)
meets_version() {
  # check that semver is installed
  if [ ! $(command -v semver) ]; then
    echo_err "'semver' is not installed - install with 'npm i -g semver'"
    return 1
  else
    semver --range "$2" "$1" >/dev/null
  fi
}

# show the sizes of the input dirs, sorted largest to smallest
dir_sizes() {
  du -skx "$@" | sort --numeric-sort --reverse
}

# courtesy of https://stackoverflow.com/a/3352015
trim() {
  local var="$*"
  # remove leading whitespace characters
  var="${var#"${var%%[![:space:]]*}"}"
  # remove trailing whitespace characters
  var="${var%"${var##*[![:space:]]}"}"
  echo -n "$var"
}

# use ssh-agent and ssh-add to setup the SSH key for accessing LI repos
ssh_add_li_key() {
  # start ssh-agent if it's not already running for this session
  if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval $(ssh-agent)
  fi
  expect <<EndOfSSHExpect
        # add the SSH key using ssh-add with expect
        spawn ssh-add $HOME/.ssh/mistewar_at_linkedin.com_ssh_key
        expect "Enter passphrase for $HOME/.ssh/mistewar_at_linkedin.com_ssh_key:"
        # SSH key has no password
        send "\r"
        expect eof
EndOfSSHExpect
echo "Added SSH key"
}

