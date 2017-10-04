# Create links for dotfiles

# colors
source "./.bash_colors"

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

# inputrc
links[".inputrc"]=".inputrc"

# gitignore
links[".gitignore"]=".gitignore"

# tmux
links[".tmux.conf"]=".tmux.conf"

# bundler
links[".bundle"]=".bundle"

# rubocop
links[".rubocop.yml"]=".rubocop.yml"

# platform-specific
platform=''
uname_str=$(uname)
if [ "$uname_str" == "Darwin" ]; then  # Mac
    # ssh
    links[".ssh/config"]=".ssh-config-mac"

elif [ "$uname_str" == "Linux" ]; then  # Linux desktop and termux on Android
    # ssh
    links[".ssh/config"]=".ssh-config-linux"
fi

# create the links
for i in "${!links[@]}"
do
  echo -n "$HOME/$i => $checkoutdir/${links[$i]}"
  if [ -L "$HOME/$i" ]
  then
    echo -e " ${COLOR_FG_RED}(symlink already exists, skipping)${COLOR_RESET}"
    continue
  fi
  if [ -e "$HOME/$i" ]
  then
    echo -ne " ${COLOR_FG_BOLD_BLUE}(file exists, renamed to '$HOME/$i-old')${COLOR_RESET}"
    mv "$HOME/$i" "$HOME/$i-old"
  fi
  ln -s "$checkoutdir/${links[$i]}" "$HOME/$i"
  echo -e " [${COLOR_FG_GREEN}OK${COLOR_RESET}]"
done
