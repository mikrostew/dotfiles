#!/usr/bin/env bash
# This will process the script definitions in script-gen/ and convert those
# into executable scripts in scripts/

COLOR_RESET='\033[0m'
COLOR_FG_RED='\033[0;31m'

# echo to stderr with red text
echo_err() {
  echo -e "${COLOR_FG_RED}$@${COLOR_RESET}" >&2
}

on_error() {
  exit_code="$?"
  # TODO: not all errors will come from lines in files
  echo_err "[ERROR] $script_file: line $current_line"
  echo_err " --> $line"
  exit "$exit_code"
}

trap on_error ERR

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

# TODO: better name for this
print_function() {
  type "$1" | sed -e "/^$1 is a function/d;" -e 's/[[:space:]]*$//'
  # TODO: error checking, exit if not a function
}

# read all the files in script-gen/
# (assuming this is run from the base dir of this repo)
for script_file in script-gen/*
do
  # this is where the file will be output
  new_file_name="${script_file/script-gen/scripts}"

  # read file contents
  file_contents=$(<"$script_file")

  # variable and function imports
  declare -A var_imports
  declare -A var_import_sources
  declare -A function_imports
  declare -A function_import_sources

  # imports and generated things in the script
  import_lines=()
  # other lines from the input script that are not imports
  other_lines=()
  # keep track of the current line number for errors
  current_line=0
  while IFS= read -r line
  do
    current_line=$(( current_line + 1 ))

    if [[ "$line" =~ ^@import\ ([A-Z_]*)\ from\ ([A-Za-z_\.]*)$ ]]
    then
      # @import VARIABLE from file (all caps is global var)
      var_name="${BASH_REMATCH[1]}"
      file_name="${BASH_REMATCH[2]}"
      var_value="${!var_name}"
      source "$file_name"

      # verify that multiple imports of the same thing do not conflict
      if [ -n "${var_imports[$var_name]}" ] && [ "$var_value" != "${var_imports[$var_name]}" ]
      then
        echo_err "[ERROR] conflicting definitions of variable '$var_name'"
        echo_err " --> $file_name: $var_value"
        echo_err " --> ${var_import_sources[$var_name]}: ${var_imports[$var_name]}"
        exit 1
      fi

      # TODO: verify that the variable is actually used in the script (as best I can tell), and show a warning if not

      # add to variable import arrays
      var_imports[$var_name]="$var_value"
      var_import_sources[$var_name]="$file_name"

    elif [[ "$line" =~ ^@import\ ([a-z_]*)\ from\ ([A-Za-z_\.]*)$ ]]
    then
      # @import function from file (lowercase is a function)
      func_name="${BASH_REMATCH[1]}"
      file_name="${BASH_REMATCH[2]}"
      source "$file_name"

      # also import dependencies of the function
      # right now this is at most 2 lines past the function declaration
      func_dependencies="$(grep -A2 "^${func_name}()" $file_name)"
      # whatever, just do this inline for now...
      while IFS= read -r dep_line
      do
        if [[ "$dep_line" =~ \#\ @global\ ([A-Z_,]*)$ ]]
        then
          var_names="${BASH_REMATCH[1]}"
          # split these on comma and/or space (see https://stackoverflow.com/a/10586169/)
          IFS=', ' read -r -a var_import_names <<< "$var_names"
          for var_name in "${var_import_names[@]}"
          do
            var_value="${!var_name}"

            # verify that multiple imports of the same thing do not conflict
            if [ -n "${var_imports[$var_name]}" ] && [ "$var_value" != "${var_imports[$var_name]}" ]
            then
              echo_err "[ERROR] conflicting definitions of variable '$var_name'"
              echo_err " --> $file_name: $var_value"
              echo_err " --> ${var_import_sources[$var_name]}: ${var_imports[$var_name]}"
              exit 1
            fi

            # add to variable import arrays
            var_imports[$var_name]="$var_value"
            var_import_sources[$var_name]="$file_name"
          done

        elif [[ "$dep_line" =~ ^@function\ ([a-z_,]*)$ ]]
        then
          # TODO: function imports
          echo "TODO"
        fi

      done <<< "$func_dependencies"

      import_lines+=( "$(print_function $func_name)" )
    # TODO: option to generate help docs
    else
      # no import
      other_lines+=( "$line" )
    fi
  done <<< "$file_contents"

  # build variable and function imports
  var_import_lines=()
  for var_name in "${!var_imports[@]}"
  do
    var_import_lines+=( "$var_name='${var_imports[$var_name]}'" ) # single quotes around value
  done

  # join imports and other lines (with newlines)
  with_imports="$(
    IFS=$'\n';
    echo "${var_import_lines[*]}" | sort;
    echo "${import_lines[*]}";
    echo "${other_lines[*]}";
  )"

  # strip any comments and blank lines
  no_comments="$(echo "$with_imports" | sed '/^[[:blank:]]*#/d;/^[[:blank:]]*$/d;')"

  # add a header and shebang to the beginning
  with_header="$(file_header "$script_file" "$no_comments")"

  # write the file, ensuring that it has executable bits set
  echo "$script_file -> $new_file_name"
  echo "$with_header" > "$new_file_name"
  chmod +x "$new_file_name"

  # clear arrays
  unset var_imports
  unset var_import_sources
  unset function_imports
  unset function_import_sources
done

