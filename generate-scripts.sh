#!/usr/bin/env bash
# This will process the script definitions in script-gen/ and convert those
# into executable scripts in scripts/

COLOR_RESET='\033[0m'
COLOR_FG_RED='\033[0;31m'

declare -A sourced_files=()

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

# check for required commands
requirement_check() {
  local cmd="$1"
  local how_to_install="$2"
  if [ ! $(command -v $cmd) ]; then
    echo_err "[ERROR] Command '$cmd' is required for this script, but not installed"
    echo_err "To install: $how_to_install"
    return 1
  else
    return 0
  fi
}

cmd_requirement_function() {
  print_function requirement_check
}

print_function() {
  type "$1" | sed -e "/^$1 is a function/d;" -e 's/[[:space:]]*$//'
  # TODO: error checking, exit if not a function
}

# add variable to imports
import_variable() {
  # arguments:
  local _var_name="$1"
  local _var_value="$2"
  local _from_file="$3"

  # don't re-source files that have already been sourced
  if [ "${sourced_files[$_from_file]}" != "yes" ]
  then
    source "$_from_file"
    sourced_files[$_from_file]='yes'
  fi

  # TODO: verify that the variable is actually used in the script (as best I can tell), and show a warning if not

  # add to variable import arrays
  var_imports[$_var_name]="$_var_value"
  var_import_sources[$_var_name]="$_from_file"
}

get_sourced_files() {
  # TODO: convert this to absolute path if it is relative
  local _from_file="$1"
  local _dep_file_arr=( "$_from_file" )

  sourced_files="$(grep "^source " "$_from_file" | sed 's/^source //g')"
  if [ -n "$sourced_files" ]
  then
    for _file in $sourced_files
    do
      full_path="$(eval echo $_file)"
      _dep_file_arr+=( "$full_path" )
      dep_sources=( $(get_sourced_files "$full_path") )
      _dep_file_arr+=( "${dep_sources[@]}" )
    done
  fi

  echo "${_dep_file_arr[@]}"
}

# add function (and any dependencies) to imports
import_function() {
  # arguments:
  local _func_name="$1"
  local _from_file="$2"

  # don't re-source files that have already been sourced
  if [ "${sourced_files[$_from_file]}" != "yes" ]
  then
    source "$_from_file"
    sourced_files[$_from_file]='yes'
  fi

  local _func_value="$(print_function "$_func_name")"

  # if we've already seen the import, don't re-import
  if [ -n "${func_imports[$_func_name]}" ]
  then
    return 0
  fi

  # not imported yet, so add to variable import arrays
  func_imports[$_func_name]="$_func_value"
  func_import_sources[$_func_name]="$_from_file"

  # get all files that are sourced from the main input file,
  # because dependent functions may be in some other file
  dep_files=( $(get_sourced_files "$_from_file") )

  # also import dependencies of the function
  # right now this is at most 3 lines past the function declaration
  func_dependencies="$(grep -A3 "^${func_name}()" "${dep_files[@]}")"
  # whatever, just do this inline for now...
  while IFS= read -r dep_line
  do
    # TODO: rename to @uses_vars?
    if [[ "$dep_line" =~ \#\ @global\ ([A-Z0-9_,]*)$ ]]
    then
      # @global VAR1,VAR2
      var_names="${BASH_REMATCH[1]}"
      # split these on comma and/or space (see https://stackoverflow.com/a/10586169/)
      IFS=', ' read -r -a var_import_names <<< "$var_names"
      for var_name in "${var_import_names[@]}"
      do
        var_value="${!var_name}"
        import_variable "$var_name" "$var_value" "$_from_file"
      done
    # TODO: rename to @uses_funcs?
    elif [[ "$dep_line" =~ \#\ @function\ ([a-z0-9_,]*)$ ]]
    then
      # @function some_func,some_func_2
      func_names="${BASH_REMATCH[1]}"
      # split these on comma and/or space (see https://stackoverflow.com/a/10586169/)
      IFS=', ' read -r -a func_import_names <<< "$func_names"
      for func_name in "${func_import_names[@]}"
      do
        import_function "$func_name" "$_from_file"
      done
    elif [[ "$dep_line" =~ \#\ @uses_cmds\ (.*)$ ]]
    then
      cmd_names="${BASH_REMATCH[1]}"
      add_cmd_requirements "$cmd_names"
    fi
  done <<< "$func_dependencies"

  # TODO: verify that the function is actually used in the script (as best I can tell), and show a warning if not
}

add_cmd_requirements() {
  local cmd_names_string="$1"

  # split these on comma and/or space (see https://stackoverflow.com/a/10586169/)
  IFS=', ' read -r -a cmd_names_array <<< "$cmd_names_string"
  for cmd_name in "${cmd_names_array[@]}"
  do
    # TODO: provide better help info on how to install specific things
    # TODO: also provide platform-specific help
    how_to_install="search 'how to install $cmd_name'"
    # add command to requirements for the script
    cmd_requirements[$cmd_name]="$how_to_install"
  done
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
  declare -A func_imports
  declare -A func_import_sources
  declare -A cmd_requirements

  # lines from the input script that are not imports
  other_lines=()
  # keep track of the current line number for errors
  current_line=0
  while IFS= read -r line
  do
    current_line=$(( current_line + 1 ))

    if [[ "$line" =~ ^@import\ ([A-Z0-9_]*)\ from\ ([A-Za-z0-9_\.]*)$ ]]
    then
      # @import VARIABLE from file (all caps is global var)
      var_name="${BASH_REMATCH[1]}"
      file_name="${BASH_REMATCH[2]}"
      var_value="${!var_name}"
      import_variable "$var_name" "$var_value" "$file_name"
    elif [[ "$line" =~ ^@import\ ([a-z0-9_]*)\ from\ ([A-Za-z0-9_\.]*)$ ]]
    then
      # @import function from file (lowercase is a function)
      func_name="${BASH_REMATCH[1]}"
      file_name="${BASH_REMATCH[2]}"
      import_function "$func_name" "$file_name"
    elif [[ "$line" =~ ^@uses_cmds\ (.*)$ ]]
    then
      cmd_names="${BASH_REMATCH[1]}"
      add_cmd_requirements "$cmd_names"
    # TODO: option to generate help docs
    else
      # no import
      other_lines+=( "$line" )
    fi
  done <<< "$file_contents"

  # build variable and function imports
  var_import_lines=()
  var_keys="$(for key in "${!var_imports[@]}"; do echo "$key"; done | sort | tr '\n' ' ')" # sort keys
  for var_name in $var_keys
  do
    var_import_lines+=( "$var_name='${var_imports[$var_name]}'" ) # single quotes around value
  done
  func_import_lines=()
  func_keys="$(for key in "${!func_imports[@]}"; do echo "$key"; done | sort | tr '\n' ' ')" # sort keys
  for func_name in $func_keys
  do
    func_import_lines+=( "${func_imports[$func_name]}" )
  done

  # build cmd requirement checking
  cmd_requirement_lines=()
  if [ "${#cmd_requirements[@]}" -gt 0 ]
  then
    # add the function the check command requirements
    func_import_lines+=( "$(cmd_requirement_function)" )
    cmd_requirement_lines+=( 'combined_return=0' )
    for cmd_name in "${!cmd_requirements[@]}"
    do
      how_to_install="${cmd_requirements[$cmd_name]}"
      cmd_requirement_lines+=( "requirement_check $cmd_name \"$how_to_install\"" )
      cmd_requirement_lines+=( 'combined_return=$(( combined_return + $? ))' )
    done
    cmd_requirement_lines+=( 'if [ "$combined_return" != 0 ]; then exit $combined_return; fi' )
  fi

  # join imports and other lines (joined with newlines)
  with_imports="$(
    IFS=$'\n';
    echo "${var_import_lines[*]}";
    echo "${func_import_lines[*]}";
    echo "${cmd_requirement_lines[*]}";
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
  unset func_imports
  unset func_import_sources
  unset cmd_requirements
done

