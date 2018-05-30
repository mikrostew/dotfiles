# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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

# if not interactive, return (if flags do not contain "i")
case $- in
    *i*) ;;
      *) return;;
esac

# directory where the dotfiles repo is checked out
export DOTFILES_DIR="$(dirname "$(readlink "$HOME/.bashrc")")"

# so I can use 'require' instead of 'source'
source "$DOTFILES_DIR/.bash_require"

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
require "$DOTFILES_DIR/.bash_colors"

# git / svn status
require "$DOTFILES_DIR/.bash_repo_status"

# prompt string
# see https://www.gnu.org/software/bash/manual/bash.html#Controlling-the-Prompt
# single quotes so these are included as-is, and evaluated for every prompt
ps_time_24h='\t'
ps_user='\u'
ps_host='\h'
ps_pwd='\w'
ps_repo_status='$(repo_status)'
PS1="\n($ps_time_24h) "\
"${COLOR_FG_BOLD_BLACK}$ps_user${COLOR_RESET}"\
"@${COLOR_FG_BOLD_BLACK}$ps_host${COLOR_RESET}"\
":${COLOR_FG_BOLD_BLACK}$ps_pwd/${COLOR_RESET}"\
"  $ps_repo_status\n\$ "


# aliases and functions
require "$DOTFILES_DIR/.bash_aliases"

# git aliases and functions
require "$DOTFILES_DIR/.bash_git"

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

# travis gem
[ -f "$HOME/.travis/travis.sh" ] && require "$HOME/.travis/travis.sh"

# run version checks async to speed up load time
# should only run into version issues when first setting up a system
(
  min_version_check "bash" "4.*.*" "bash --version | sed -n -E 's/[^0-9]*([0-9]+\.[0-9]+\.[0-9]+[^ ]*).*/\1/p'";
  min_version_check "git" "2.14.*" "git --version | awk '{print \$3}'" 'brew install git';
  min_version_check "jq" "1.5.*" "jq --version | sed 's/jq-//'" 'brew install jq';
  min_version_check "expect" "5.*.*" "expect -version | awk '{print \$3}'" 'brew install expect';
  min_version_check "bats" "0.4.*" "bats --version | awk '{print \$2}'" 'brew install bats';
  min_version_check "curl" "7.*.*" "curl --version | head -n1 | awk '{print \$2}'" 'brew install curl';
  # sponge doesn't give a version, so as long as it exists that's fine
  min_version_check "sponge" "1.0.0" "which sponge >/dev/null && echo 1.0.0" 'brew install moreutils';
) & disown

# TODO: verify that the links to these dotfiles haven't changed (run async)

# show uptime, like " 9:45  up 2 days, 17:09, 7 users, load averages: 1.63 3.29 5.36"
echo -e "uptime: $COLOR_FG_BOLD_BLUE$(uptime)$COLOR_RESET"

if platform_is_mac; then
  bashrc_finish=$(gdate +%s%3N)
else
  bashrc_finish=$(date +%s%3N)
fi

bashrc_run_time=$((bashrc_finish - bashrc_start))
echo -e "~/.bashrc loaded in $COLOR_FG_BOLD_BLUE${bashrc_run_time}ms$COLOR_RESET"

# log the startup time
echo "$bashrc_start $bashrc_run_time" >> "$HOME/Dropbox/log/bashrc-startup-time"

# installers like to add things to the end of this file, so prevent that stuff from running
return 0
