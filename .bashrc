# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# if not interactive, return (if flags do not contain "i")
case $- in
    *i*) ;;
      *) return;;
esac

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

# prompt string:
# replace home dir in PWD with ~,
# add a trailing slash to the PWD if there is not one
MY_PS='$(echo "$PWD" | sed -e "s|^$HOME|~|" -e "s|/*$|/|")'
# colors used in the prompt
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[1;34m'
COLOR_RESET='\033[0m'
# show info about what kind of repo we're in
# some code and ideas from:
# - http://zanshin.net/2012/03/09/wordy-nerdy-zsh-prompt/
# - https://github.com/sjl/oh-my-zsh/commit/3d22ee248c6bce357c018a93d31f8d292d2cb4cd
# - https://github.com/magicmonty/bash-git-prompt
repo_status() {
    git_status=$(git status 2>/dev/null)
    if [ $? -eq 0 ]; then
        # count occurrences of each case
        git_status_porcelain=$(git status --porcelain --untracked-files=all --branch)
        git_num_conflict=0
        git_num_modified=0
        git_num_untracked=0
        git_num_staged=0
        while IFS='' read -r line; do
            XY=${line:0:2}
            case "$XY" in
                \#\#) git_branch_line="$line" ;;
                U?)    ((git_num_conflict++)) ;;  # unmerged
                ?U)    ((git_num_conflict++)) ;;  # unmerged
                DD)    ((git_num_conflict++)) ;;  # unmerged (both deleted)
                AA)    ((git_num_conflict++)) ;;  # unmerged (both added)
                ?[MD]) ((git_num_modified++)) ;;  # modified/deleted in working tree
                \?\?)  ((git_num_untracked++)) ;; # untracked in index and working tree
            esac
            case "$XY" in
                [MARCD]?) ((git_num_staged++)) ;; # modified/added/renamed/copied/deleted in index
            esac
        done <<< "$git_status_porcelain"

        git_branch=$( ( [[ "$git_status" =~ On\ branch\ ([^$'\n']+) ]] && echo ${BASH_REMATCH[1]} ) || echo '?' )
        git_rebase=$( ( [[ "$git_status" =~ rebase\ in\ progress ]] && echo '<rebase>' ) || echo '' )
        git_detached=$( ( [[ "$git_status" =~ HEAD\ detached ]] && echo '<detached>' ) || echo '' )
        git_ahead=$( ( [[ "$git_status" =~ Your\ branch\ is\ ahead\ of\ .*\ by\ ([0-9]+)\ commit ]] && echo "+${COLOR_BLUE}${BASH_REMATCH[1]}${COLOR_RESET}" ) || echo '' )
        git_behind=$( ( [[ "$git_status" =~ Your\ branch\ is\ behind\ .*\ by\ ([0-9]+)\ commit ]] && echo "-${COLOR_BLUE}${BASH_REMATCH[1]}${COLOR_RESET}" ) || echo '' )

        git_staged=$( [ "$git_num_staged" -gt 0 ] && echo "${COLOR_GREEN}*$git_num_staged${COLOR_RESET}" )
        git_modified=$( [ "$git_num_modified" -gt 0 ] && echo "${COLOR_RED}+$git_num_modified${COLOR_RESET}" )
        git_untracked=$( [ "$git_num_untracked" -gt 0 ] && echo "${COLOR_YELLOW}?$git_num_untracked${COLOR_RESET}" )
        git_conflict=$( [ "$git_num_conflict" -gt 0 ] && echo "${COLOR_RED}!$git_num_conflict${COLOR_RESET}" )

        git_ok=$( [[ "$git_status" =~ nothing\ to\ commit|working\ directory\ clean ]] && echo "${COLOR_GREEN}--${COLOR_RESET}" )
        # join stat strings with commas
        git_stat_str=($git_staged $git_modified $git_untracked $git_conflict $git_ok)
        git_stat_str=$(IFS=, ; echo "${git_stat_str[*]}")
        echo -e " ${COLOR_BLUE}git${COLOR_RESET}|${COLOR_BLUE}$git_rebase$git_detached$git_branch${COLOR_RESET}$git_behind$git_ahead|$git_stat_str"
    elif [ -d .svn ]; then
        svn_info=$(svn info 2>/dev/null)
        svn_path=$( ( [[ "$svn_info" =~ URL:\ ([^$'\n']+) ]] && echo ${BASH_REMATCH[1]} ) || echo '?' )
        svn_protocol=$(expr "$svn_path" : '\([a-z]\+://\)') # remove the svn:// or https:// from the start of the repo
        svn_revision=$( [[ "$svn_info" =~ Revision:\ ([0-9]+) ]] && echo ${BASH_REMATCH[1]} )
        svn_stat=$(svn status 2>/dev/null)
        svn_dirty=$( ( [[ "$svn_stat" =~ [?!AM]([[:space:]]+[^$'\n']+) ]] && echo 'dirty' ) || echo "${COLOR_GREEN}ok${COLOR_RESET}" )
        echo -e " ${COLOR_BLUE}svn${COLOR_RESET}|${COLOR_BLUE}${svn_path#$svn_protocol}${COLOR_RESET}@${COLOR_BLUE}$svn_revision${COLOR_RESET} $svn_dirty"
    else
        echo ''
    fi
}
PS1='\n(\t) \u@\h:$(eval "echo ${MY_PS}")$(repo_status)\n\$ '

# If this is an xterm set the title to user@host:dir
# (this will overwrite the terminal title after every command - don't want that)
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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

# chruby - source and set a default ruby
source /usr/local/share/chruby/chruby.sh
chruby ruby-2

# 256 color support
export TERM=xterm-256color

