#!/usr/bin/env bash
# This will process the script definitions in script-gen/ and convert those
# into executable scripts in scripts/

# create a header for the generated script file
file_header() {
  input_file="$1"
  file_contents="$2"
  echo "#!/usr/bin/env bash"
  echo "###########################################################################"
  echo "# DO NOT EDIT! This script was auto-generated. To update this script, edit"
  echo "# the file $input_file, and run './generate-scripts.sh'"
  echo "###########################################################################"
  echo ""
  echo "$file_contents"
}

# read all the files in script-gen/
# (assuming this is run from the base dir of this repo)
for script_file in script-gen/*
do
  # this is where the file will be output
  new_file_name="${script_file/script-gen/scripts}"

  # read file contents
  file_contents=$(<"$script_file")

  # imports and generated things in the script
  import_lines=()
  while read -r line; do
    # do the imports here
    if [[ "$line" =~ ^@@import\ ([A-Za-z_]*)\ from\ ([A-Za-z_\.]*)$ ]]
    then
      # import variable from file
      var_name="${BASH_REMATCH[1]}"
      file_name="${BASH_REMATCH[2]}"
      source "$file_name"
      import_lines+=( "$var_name='${!var_name}'" )
    # TODO: generate help docs
    # TODO: import functions
    else
      # no import
      import_lines+=( "$line" )
    fi
  done <<< "$file_contents"
  # join with newlines
  with_imports="$( IFS=$'\n'; echo "${import_lines[*]}" )"

  # strip any remaining comments and blank lines
  no_comments="$(echo "$with_imports" | sed '/^[[:blank:]]*#/d;/^[[:blank:]]*$/d;')"

  # add a header and shebang to the beginning
  with_header="$(file_header "$script_file" "$no_comments")"

  # write the file, ensuring that it has executable bits set
  echo "$script_file -> $new_file_name"
  echo "$with_header" > "$new_file_name"
  chmod +x "$new_file_name"
done

