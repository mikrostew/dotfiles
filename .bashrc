# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# if not interactive, return (if flags do not contain "i")
case $- in
    *i*) ;;
      *) return;;
esac

# should I switch to zsh? now that it's the default on OSX? maybe
# see:
# - https://dev.to/saltyshiomix/a-guide-for-upgrading-macos-to-catalina-and-migrating-the-default-shell-from-bash-to-zsh-4ep3
# - https://scriptingosx.com/2019/06/moving-to-zsh/
# - https://apple.stackexchange.com/questions/361870/what-are-the-practical-differences-between-bash-and-zsh
# - https://www.reddit.com/r/linux/comments/1csl7c/bash_vs_zsh/

# in the meantime, so I don't keep seeing that deprecation warning
# (from https://support.apple.com/en-us/HT208050, the link in the warning message)
export BASH_SILENCE_DEPRECATION_WARNING=1

# also silence deprecation warnings about Tcl/Tk
# (if I need it in the future I can install with homebrew)
export TK_SILENCE_DEPRECATION=1

# because using `ls` for any file containing spaces in the name on the Raspberry Pi surrounds the name with single quotes
# (see https://unix.stackexchange.com/q/258679 - I don't care about the controversy there, I just don't wnat the quotes)
export QUOTING_STYLE=literal

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

# set extended globbing, see https://www.linuxjournal.com/content/bash-extended-globbing
shopt -s extglob

# spelling correction for directory names
shopt -s cdspell

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

# prompt string
# see https://www.gnu.org/software/bash/manual/bash.html#Controlling-the-Prompt
# single quotes so these are included as-is, and evaluated for every prompt
ps_user='\u'
ps_host='\h'
ps_pwd='\w'
PS1="${COLOR_RESET}\n"\
"${COLOR_FG_BOLD_BLACK}$ps_user${COLOR_RESET}"\
"@${COLOR_FG_BOLD_BLACK}$ps_host${COLOR_RESET}"\
":${COLOR_FG_BOLD_BLACK}$ps_pwd/${COLOR_RESET}"\
"\n\$ "


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
path_python="$HOME/Library/Python/3.7/bin" # for pipx, userpath, etc.
path_python_globals="$HOME/.local/bin" # for packages installed with pipx
# all together now
export PATH="$path_homebrew:$path_yarn:$path_scripts:$path_rust:$path_python:$path_python_globals:$PATH"

# for bash-completion after upgrading to bash 4.x with homebrew
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# formatting for `ri` documentation
export RI="-T --format=ansi"

# 256 color support
export TERM=xterm-256color

# fix the colors for ls on dark background
# (from https://askubuntu.com/a/466203 - doesn't work for OSX)
#LS_COLORS="$LS_COLORS:di=0;35:"; export LS_COLORS
# (from https://softwaregravy.wordpress.com/2010/10/16/ls-colors-for-mac/)
# this is the default, except for bold blue directories
export LSCOLORS=Exfxcxdxbxegedabagacad

# loading things into the shell

# volta - stable and fast enough to always load this
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# need this for v-web, until we migrate to Node 12?
export NODE_OPTIONS="--max-old-space-size=8192"

# Visual Studio Code, for OSX
if [ -d "/Applications/Visual Studio Code.app" ]
then
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

# nvm
# not done automatically, because this slows down new session startup, and I use Volta now
load_nvm() {
  echo_info "Loading nvm..."
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

# chruby - done automatically because I frequently use Ruby
# (this is the same location on mac and linux)
if [ -f "/usr/local/share/chruby/chruby.sh" ]; then
  source /usr/local/share/chruby/chruby.sh
  chruby ruby-2.6
  ruby -v
fi

# latex
# not done automatically because I infrequently use TeX/LaTeX, and it clutters the path
load_latex() {
  echo_info "Adding TeX/LaTeX binaries to the path..."
  export PATH="/Library/TeX/texbin:$PATH"
  echo "$PATH"
}


# ssh key stuff for RHEL at linkedin
if [ -x /usr/bin/keychain ]
then
  MY_NAME=$(whoami)
  MY_HOST=$(hostname)
  MY_KEY="${HOME}/.ssh/${MY_NAME}_at_linkedin.com_ssh_key"
  MY_KEYCHAIN_ENV="${HOME}/.keychain/${MY_HOST}-sh"

  if [ -f "$MY_KEY" ]
  then
    # starts ssh-agent, adds the key(s), and creates the env file
    /usr/bin/keychain "$MY_KEY"
    # has env vars for SSH agent stuff (PIDs, etc.)
    source "$MY_KEYCHAIN_ENV"
  fi
fi


# Qt (for Python)
# (these recommendations are from homebrew after `brew install pyqt`)
# If you need to have qt first in your PATH run:
#   echo 'export PATH="/usr/local/opt/qt/bin:$PATH"' >> ~/.bash_profile
#
# For compilers to find qt you may need to set:
export LDFLAGS="-L/usr/local/opt/qt/lib"
export CPPFLAGS="-I/usr/local/opt/qt/include"
#
# For pkg-config to find qt you may need to set:
export PKG_CONFIG_PATH="/usr/local/opt/qt/lib/pkgconfig"


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
# (should only run into version issues when first setting up a system)
# things I could do with this:
# * combine all this into a single line somehow (maybe dotfile links separately?), and display in red on the top line of the console
# * somehow showing this in the tmux status line as an error
# * move all this into a config file, and have a single command to read that, do the version checks, and combine the status
(
  min-version-check "bash" ">=4" "bash --version | sed -n -E 's/[^0-9]*([0-9]+\.[0-9]+\.[0-9]+[^ ]*).*/\1/ p'" 'brew install bash';
  min-version-check "git" "^2.14" "git --version | awk '{print \$3}'" 'brew install git';
  min-version-check "jq" "^1.5" "jq --version | sed 's/jq-//'" 'brew install jq';
  min-version-check "expect" "^5.0" "expect -version | awk '{print \$3}'" 'brew install expect';
  platform_is_mac && min-version-check "bats-core" "^1.0" "bats --version | awk '{print \$2}'" 'brew install bats-core' 'which bats';
  min-version-check "curl" "^7.0" "curl --version | head -n1 | awk '{print \$2}'" 'brew install curl';
  # sponge doesn't give a version, so as long as it exists that's fine
  min-version-check "sponge" "1.0.0" "which sponge >/dev/null && echo 1.0.0" 'brew install moreutils';
  platform_is_mac && min-version-check "terminal-notifier" "^2.0" "terminal-notifier -version | sed -e 's/terminal-notifier //' -e 's/\.$//'" 'brew install terminal-notifier';
  # also verify that the links to these dotfiles haven't changed
  verify_dotfile_links
) & disown

# show a clock in the top right corner of the terminal, formatted like "Mon May 20, 14:36 PDT"
#"$HOME/src/term-clock/term-clock.sh" "$$" --format "%a %b %d, %H:%M %Z" &

# to log the startup time later
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
    #printf '\e[3;10;10t'    # move window to upper left but not all the way in the corner
    printf '\033[8;32;96t' # 96W x 32H chars
  fi
fi

if platform_is_mac; then
  bashrc_finish=$(gdate +%s%3N)
else
  bashrc_finish=$(date +%s%3N)
fi
bashrc_run_time=$((bashrc_finish - bashrc_start))

# log the startup time
echo "$bashrc_start $bashrc_run_time" >> "$HOME/Sync/machines/bashrc-startup-time-$HOST_NAME"
echo -e ".bashrc loaded in $COLOR_FG_BOLD_BLUE${bashrc_run_time}ms$COLOR_RESET ($SESSION_TYPE session, tab #$tab_number)"

# some installers like to add things to this file, so prevent that stuff from running
return 0
export VOLTA_HOME="/Users/mistewar/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
