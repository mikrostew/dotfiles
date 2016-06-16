# Create links for dotfiles

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
  echo "link   : $i"
  echo "target : ${links[$i]}"
  ln -s "$HOME/${links[$i]}" "$checkoutdir/$i"
done
