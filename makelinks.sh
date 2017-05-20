# Create links for dotfiles

BLUE="\033[1;34m"
GREEN="\033[0;32m"
RESET="\033[0m"

# TODO - input the directory where the repo is checked out
checkoutdir="$HOME/dotfiles"

# use bash 4.x associative arrays
declare -A links

# vim
links[".vimrc"]=".vimrc"
links[".vim"]=".vim"

# bash
links[".bash_profile"]=".bash_profile"
links[".bashrc"]=".bashrc"
links[".bash_aliases"]=".bash_aliases"
links[".bash_repo_status"]=".bash_repo_status"

# inputrc
links[".inputrc"]=".inputrc"

# gitignore
links[".gitignore"]=".gitignore"

# tmux
links[".tmux.conf"]=".tmux.conf"

# bundler
links[".bundle"]=".bundle"

# ssh
links[".ssh/config"]=".ssh-config"

# rubocop
links[".rubocop.yml"]=".rubocop.yml"

# create the links
for i in "${!links[@]}"
do
  echo -n "$HOME/$i => $checkoutdir/${links[$i]}"
  if [ -e "$HOME/$i" ]
  then
    echo -ne " ${BLUE}(file exists, renamed to '$HOME/$i-old')${RESET}"
    mv "$HOME/$i" "$HOME/$i-old"
  fi
  ln -s "$checkoutdir/${links[$i]}" "$HOME/$i"
  echo -e " [${GREEN}OK${RESET}]"
done

