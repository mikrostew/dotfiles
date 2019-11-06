# $DOTFILES_DIR/.bash_aliases: contains extra aliases, sourced from .bashrc

source "$DOTFILES_DIR/.bash_colors"
source "$DOTFILES_DIR/.bash_shared_functions"

# color support for some commands
if platform_is_linux; then
    alias ls='ls --color=auto'
elif platform_is_mac; then
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

# disk usage - use ncdu to have a nice file browser
alias ncdu='ncdu -x -rr --color dark'

# because I type this so much
alias x='exit'

# tmux
alias tl='tmux ls'
alias ta='tmux at'

# so that tmux will display 256 colors correctly
alias tmux='TERM=xterm-256color tmux'

# Ember
alias jet='just ember test'
alias jets='just ember test --serve'

# BashRC
alias rebash='unalias -a; source $HOME/.bashrc'

# bundler
alias be='bundle exec'
alias bejb='bundle exec jekyll build'
alias bejs='bundle exec jekyll serve'
alias bi='bundle install'

# mvim
alias mm="mvim ."

# cargo
alias cb='do_cmd cargo build'
alias ct='do_cmd cargo test'
alias cta='do_cmd cargo test --all'
alias cwb='do_cmd cargo watch -x build'
alias cwt='do_cmd cargo watch -x test'

# volta
alias ⚡️='volta'

# for reading/writing notes to myself
alias notes="mvim ~/Sync/notes/"
