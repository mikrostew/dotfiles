# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# if not interactive, return (if flags do not contain "i")
case $- in
    *i*) ;;
      *) return;;
esac

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
# single quotes so these are included as-is, and re-eval-ed for every prompt
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

# If this is an xterm set the title to user@host:dir
# (this will overwrite the terminal title after every command - don't want that)
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# alias definitions
source "$DOTFILES_DIR/.bash_aliases"

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

# formatting for `ri` documentation
export RI="-T --format=ansi"

# show bash version
bash_version="$(bash --version)"
bash_version_str=""
if [[ "$bash_version" =~ ([0-9]+)\.([0-9]+)\.([0-9]+[^ ]*) ]]; then
    # want at least bash 4.x
    if [ "${BASH_REMATCH[1]}" -ge 4 ]; then
      bash_version_str="\033[1;34m${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}\033[0m"
    else
      bash_version_str="\033[1;31m${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]} (want >= 4.x)\033[0m"
    fi
else
    bash_version_str="\033[1;31m?.?.?\033[0m"
fi
echo -e " bash : $bash_version_str"

# chruby
if [ -f "/usr/local/share/chruby/chruby.sh" ]; then
    source /usr/local/share/chruby/chruby.sh
    chruby ruby-2
    echo -e " chruby : \033[1;34m$RUBY_VERSION\033[0m ($RUBY_ROOT)"
else
    echo -e " chruby : \033[1;31mnot installed\033[0m"
fi

# git
git_version="$(git --version | awk '{print $3}')"
git_version_str=""
if [[ "$git_version" =~ ([0-9]+)\.([0-9]+)\.([0-9]+[^ ]*) ]]; then
    # want at least git 2.14
    if [ "${BASH_REMATCH[1]}" -ge 2 ] && [ "${BASH_REMATCH[2]}" -ge 14 ]; then
      git_version_str="\033[1;34m${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}\033[0m"
    else
      git_version_str="\033[1;31m${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]} (want >= 2.14)\033[0m"
    fi
else
    git_version_str="\033[1;31m?.?.?\033[0m"
fi
echo -e " git : $git_version_str ($(which git))"

# 256 color support
export TERM=xterm-256color

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


# added by travis gem
[ -f /Users/mikrostew/.travis/travis.sh ] && source /Users/mikrostew/.travis/travis.sh

# yarn
export PATH="$HOME/.yarn/bin:$PATH"

# nvm
# - this slows down new tab startup, and I'm not using it right now
#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# show nvm version
# if [ -f "$NVM_DIR/nvm.sh" ]; then
#     echo -e " nvm : \033[1;34m$(nvm current)\033[0m ($NVM_BIN)"
# else
#     echo -e " nvm : \033[1;31mnot installed (or not configured)\033[0m"
# fi
