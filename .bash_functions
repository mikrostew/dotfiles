#!/usr/bin/env bash
# $DOTFILES_DIR/.bash_functions: contains extra functions, sourced from .bashrc

require "$DOTFILES_DIR/.bash_colors"
require "$DOTFILES_DIR/.bash_shared_functions"

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
      # remove line number, notify cmd, and any double quotes
      cmd="$(history | tail -n 1 | sed -e 's/^\ *[0-9]*\ *//' -e 's/[;&|]\ *notify.*$//' -e 's/"//g' )"
    fi
    local sound_name="Glass" # see /System/Library/Sounds/ for list of sounds
    # TODO: use terminal-notifier, see https://github.com/julienXX/terminal-notifier
    local script="display notification \"$cmd\" with title \"$title\" sound name \"$sound_name\""
    osascript -e "$script"
  else # Linux
    if [ -n "$cmd_string" ]; then
      cmd="$cmd_string"
    else
      # remove line number, notify cmd, and any double quotes
      cmd="$(history | tail -n 1 | sed -e 's/^\s*[0-9]\+\s*//' -e 's/[;&|]\s*notify.*$//' -e 's/"//g' )"
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

# show the sizes of the input dirs, sorted largest to smallest
dir_sizes() {
  du -skx "$@" | sort --numeric-sort --reverse
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

