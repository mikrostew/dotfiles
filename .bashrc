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
PS1="\n($ps_time_24h) "\
"${COLOR_FG_BOLD_BLACK}$ps_user${COLOR_RESET}"\
"@${COLOR_FG_BOLD_BLACK}$ps_host${COLOR_RESET}"\
":${COLOR_FG_BOLD_BLACK}$ps_pwd/${COLOR_RESET}"\
"  $ps_repo_status\n\$ "


# aliases and functions
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

# for homebrew I think?
export PATH="/usr/local/sbin:$PATH"

# for bash-completion after upgrading to bash 4.x with homebrew
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion


# formatting for `ri` documentation
export RI="-T --format=ansi"

# chruby
if [ -f "/usr/local/share/chruby/chruby.sh" ]; then
    source /usr/local/share/chruby/chruby.sh
    chruby ruby-2
fi

# 256 color support
export TERM=xterm-256color

# travis gem
[ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"

# yarn
export PATH="$HOME/.yarn/bin:$PATH"

# version checks
failed_version_checks=0
min_version_check "bash" "$(bash --version | sed -n -E 's/[^0-9]*([0-9]+\.[0-9]+\.[0-9]+[^ ]*).*/\1/p')" "4.*.*" || ((failed_version_checks++))
min_version_check "ruby" "$RUBY_VERSION" "2.2.*" "$RUBY_ROOT" || ((failed_version_checks++))
min_version_check "git" "$(git --version | awk '{print $3}')" "2.14.*" "$(which git)" || ((failed_version_checks++))
if [ $failed_version_checks -gt 0 ]; then
  echo -e "${COLOR_FG_RED}$failed_version_checks version check(s) failed${COLOR_RESET}"
else
  echo -e "All version checks ${COLOR_FG_GREEN}OK${COLOR_RESET}"
fi


if platform_is_mac; then
  bashrc_finish=$(gdate +%s%3N)
else
  bashrc_finish=$(date +%s%3N)
fi

bashrc_run_time=$((bashrc_finish - bashrc_start))
echo "~/.bashrc loaded in ${bashrc_run_time}ms"
