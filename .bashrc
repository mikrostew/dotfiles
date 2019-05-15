# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# if not interactive, return (if flags do not contain "i")
case $- in
    *i*) ;;
      *) return;;
esac

# for platform-specific things
platform_is_mac() {
    [ "$(uname)" == "Darwin" ] # OSX
}
platform_is_linux() {
    [ "$(uname)" == "Linux" ] # Linux desktop and termux on Android
}

if platform_is_mac; then
  bashrc_start=$(gdate +%s%3N)
else
  bashrc_start=$(date +%s%3N)
fi

# determine if this is a local or remote session
# (adapted from https://unix.stackexchange.com/a/9607)
SESSION_TYPE=local
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [[ "$(ps -o comm= -p $PPID)" =~ sshd ]]
then
  SESSION_TYPE=remote/ssh
fi

# directory where the dotfiles repo is checked out
export DOTFILES_DIR="$(dirname "$(readlink "$HOME/.bashrc")")"

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

# colors:
source "$DOTFILES_DIR/.bash_colors"

# git / svn status
source "$DOTFILES_DIR/.bash_repo_status"

# prompt string
# see https://www.gnu.org/software/bash/manual/bash.html#Controlling-the-Prompt
# single quotes so these are included as-is, and evaluated for every prompt
ps_time_24h='\t'
ps_user='\u'
ps_host='\h'
ps_pwd='\w'
ps_repo_status='$(repo_status)'
PS1="${COLOR_RESET}\n($ps_time_24h) "\
"${COLOR_FG_BOLD_BLACK}$ps_user${COLOR_RESET}"\
"@${COLOR_FG_BOLD_BLACK}$ps_host${COLOR_RESET}"\
":${COLOR_FG_BOLD_BLACK}$ps_pwd/${COLOR_RESET}"\
"  $ps_repo_status\n\$ "


# aliases
source "$DOTFILES_DIR/.bash_aliases"

# git aliases and functions
source "$DOTFILES_DIR/.bash_git"

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

# PATH
# homebrew, yarn, scripts in this repo
path_homebrew="/usr/local/sbin"
path_yarn="$HOME/.yarn/bin"
path_scripts="$DOTFILES_DIR/scripts"
path_rust="$HOME/.cargo/bin"
# all together now
export PATH="$path_homebrew:$path_yarn:$path_scripts:$path_rust:$PATH"

# for bash-completion after upgrading to bash 4.x with homebrew
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# formatting for `ri` documentation
export RI="-T --format=ansi"

# 256 color support
export TERM=xterm-256color


# loading things into the shell

# volta - stable and fast enough to always load this
export VOLTA_HOME="$HOME/.volta"
[ -s "$VOLTA_HOME/load.sh" ] && . "$VOLTA_HOME/load.sh"
export PATH="$VOLTA_HOME/bin:$PATH"

# nvm
# not done automatically, because this slows down new session startup, and I use it infrequently
load_nvm() {
  echo_info "Loading nvm..."
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

# notion
# not done automatically, because some of the shims are not yet implemented
load_notion() {
  echo_info "Loading notion..."

  export NOTION_HOME="$HOME/.notion"
  [ -s "$NOTION_HOME/load.sh" ] && \. "$NOTION_HOME/load.sh"

  export PATH="${NOTION_HOME}/bin:$PATH"
}

# because I frequently screw up my installation
install_notion() {
  echo_ack "( curl -sSLf https://get.notionjs.com | bash )"
  curl -sSLf https://get.notionjs.com | bash
}

# chruby
# not done automatically because I infrequently use ruby and this clutters the path
load_chruby() {
  echo_info "Loading chruby..."
  # this is the same location on mac and linux
  if [ -f "/usr/local/share/chruby/chruby.sh" ]; then
    source /usr/local/share/chruby/chruby.sh
    chruby ruby-2
    ruby -v
  fi
}

# latex
# not done automatically because I infrequently use TeX/LaTeX, and it clutters the path
load_latex() {
  echo_info "Adding TeX/LaTeX binaries to the path..."
  export PATH="/Library/TeX/texbin:$PATH"
  echo "$PATH"
}


# functions to notify me about things

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
    # use terminal-notifier instead of osascript (see https://github.com/julienXX/terminal-notifier)
    # so that it will activate the terminal when clicked, and I don't have to re-quote everything
    terminal-notifier -message "$cmd" -title "$title" -activate 'com.googlecode.iterm2' -sound "$sound_name"
    # local script="display notification \"$cmd\" with title \"$title\" sound name \"$sound_name\""
    # osascript -e "$script"
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


# run version checks async to speed up load time
# should only run into version issues when first setting up a system
(
  min-version-check "bash" "^4.0.0" "bash --version | sed -n -E 's/[^0-9]*([0-9]+\.[0-9]+\.[0-9]+[^ ]*).*/\1/ p'" 'brew install bash';
  min-version-check "git" "^2.14.0" "git --version | awk '{print \$3}'" 'brew install git';
  min-version-check "jq" "^1.5.0" "jq --version | sed 's/jq-//'" 'brew install jq';
  min-version-check "expect" "^5.0.0" "expect -version | awk '{print \$3}'" 'brew install expect';
  min-version-check "bats-core" "^1.0.0" "bats --version | awk '{print \$2}'" 'brew install bats-core' 'which bats';
  min-version-check "curl" "^7.0.0" "curl --version | head -n1 | awk '{print \$2}'" 'brew install curl';
  # sponge doesn't give a version, so as long as it exists that's fine
  min-version-check "sponge" "1.0.0" "which sponge >/dev/null && echo 1.0.0" 'brew install moreutils';
  min-version-check "terminal-notifier" "^2.0.0" "terminal-notifier -version | sed -e 's/terminal-notifier //' -e 's/\.$//'" 'brew install terminal-notifier';
  # also verify that the links to these dotfiles haven't changed
  verify_dotfile_links
) & disown

HOST_NAME="$(hostname)"

# show uptime, like " 9:45  up 2 days, 17:09, 7 users, load averages: 1.63 3.29 5.36"
echo -e "uptime: $COLOR_FG_BOLD_BLUE$(uptime)$COLOR_RESET"

# resize the terminal window if this is a local session
# (see https://apple.stackexchange.com/a/47841)
if [ "$SESSION_TYPE" == "local" ]
then
  # get the tab number of this session
  # NOTE: this is not bulletproof - if I close tab 0, then open a new tab, it will be tab 0
  if [ -n "$ITERM_SESSION_ID" ] && [[ "$ITERM_SESSION_ID" =~ ^w[0-9]*t([0-9]*)p[0-9]*: ]]
  then
    tab_number="${BASH_REMATCH[1]}"
  elif [ -n "$TERM_SESSION_ID" ] && [[ "$TERM_SESSION_ID" =~ ^w[0-9]*t([0-9]*)p[0-9]*: ]]
  then
    tab_number="${BASH_REMATCH[1]}"
  else
    tab_number="?"
  fi

  # if this is the first tab in this session, resize it
  if [ -z "$tab_number" ] || [ "$tab_number" == "0" ]
  then
    # see http://invisible-island.net/xterm/ctlseqs/ctlseqs.html, search "window manipulation"
    printf '\e[3;10;10t'    # move window to upper left but not all the way in the corner
    printf '\033[8;48;192t' # 192W x 48H chars
  fi
fi

if platform_is_mac; then
  bashrc_finish=$(gdate +%s%3N)
else
  bashrc_finish=$(date +%s%3N)
fi
bashrc_run_time=$((bashrc_finish - bashrc_start))

# log the startup time
echo "$bashrc_start $bashrc_run_time" >> "$HOME/Dropbox/log/bashrc-startup-time-$HOST_NAME"
echo -e ".bashrc loaded in $COLOR_FG_BOLD_BLUE${bashrc_run_time}ms$COLOR_RESET ($SESSION_TYPE session, tab #$tab_number)"

# some installers like to add things to this file, so prevent that stuff from running
return 0
