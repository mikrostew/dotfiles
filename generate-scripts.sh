#!/usr/bin/env bash
# This will process the script definitions in script-gen/ and convert those
# into executable scripts in scripts/

COLOR_RESET='\033[0m'
COLOR_FG_RED='\033[0;31m'
COLOR_FG_YELLOW='\033[0;33m'

declare -A sourced_files=()

files_generated=0
files_skipped=0

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

# compare hashes to check if the file needs to be generated
need_to_generate() {
  # arguments:
  local src_script="$1"
  local generated_script="$2"

  # if the generated file doesn't exist, then of course it should be generated
  if [ ! -f "$generated_script" ]
  then
    return 0
  fi

  # get hashfrom last file generation
  readarray -t -s5 -n1 hash_lines < "$generated_script"
  # remove the leading hash
  local prev_hash="${hash_lines[0]#\#}"

  # for the generated script, skip the header (which contains the calculated hash) and is currently 7 lines long
  local combined_hash="$(hash_for_scripts "$src_script" "$(tail -n +8 $generated_script)")"

  # if hash matches, no need to regenerate
  if [ "$combined_hash" == "$prev_hash" ]
  then
    return 1
  fi

  # otherwise have to generate
  return 0
}

# calculate the hash of the src and dest scripts
hash_for_scripts() {
  # arguments:
  local src_file="$1"
  local generated_contents="$2"

  # combine files and calculate the hash (instead of doing 2 separate hashes)
  # - using md5 because I want this to be fast and I'm not worried about collisions
  echo "$generated_contents" | cat "$src_file" - | md5 -q
}

# create a header for the generated script file
file_header() {
  # arguments:
  local input_file="$1"
  local file_contents="$2"

  # calculate the hash
  local combined_hash="$(hash_for_scripts "$input_file" "$file_contents")"

  echo "#!/usr/bin/env bash"
  echo "###########################################################################"
  echo "# DO NOT EDIT! This script was auto-generated. To update this script, edit"
  echo "# the file $input_file, and run './generate-scripts.sh'"
  echo "###########################################################################"
  echo "#$combined_hash"
  echo ""
  echo "$file_contents"
}

# generate code to exit with a message if there is an error
# NOTE: can't run this from a subshell, because it won't have access to import variables
exit_with_message() {
  # arguments:
  local varname="$1"
  local message="$2"
  local padding="$3"

  local temp=""

  # make sure it has these colors (don't import
  add_var_to_imports "COLOR_FG_RED" "$COLOR_FG_RED"
  add_var_to_imports "COLOR_RESET" "$COLOR_RESET"

  temp+="${padding}exit_code=\"\$?\"\n"
  temp+="${padding}if [ \"\$exit_code\" -ne 0 ]\n"
  temp+="${padding}then\n"
  temp+="${padding}  echo -e \"\${COLOR_FG_RED}$message\${COLOR_RESET}\" >&2\n"
  temp+="${padding}  exit \"\$exit_code\"\n"
  temp+="${padding}fi\n"
  printf -v "$varname" "$temp"
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
  local var_name="$1"
  local from_file="$2"

  # don't re-source files that have already been sourced
  if [ -n "$from_file" ] && [ "${sourced_files[$from_file]}" != "yes" ]
  then
    source "$from_file"
    sourced_files[$from_file]='yes'
  fi

  local var_value="${!var_name}"
  echo "import var $var_name with value '$var_value' from file $from_file" >&2

  # TODO: verify that the variable is actually used in the script (as best I can tell), and show a warning if not

  # add to variable import arrays
  add_var_to_imports "$var_name" "$var_value"
}

add_var_to_imports() {
  # arguments:
  # $1 is name
  # $2 is value
  var_imports[$1]="$2"
}

# add multiple variable to imports
import_multiple_variables() {
  # arguments:
  local _var_names="$1"
  local _from_file="$2"
  echo_err "import multiple vars: $_var_names"

  # split these on comma and/or space
  IFS=', ' read -r -a var_import_names <<< "$_var_names"
  for var_name in "${var_import_names[@]}"
  do
    import_variable "$var_name" "$_from_file"
  done
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

  # not imported yet, so add to function imports
  func_imports[$_func_name]="$_func_value"

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
    if [[ "$dep_line" =~ \#\ @global\ (.*)$ ]]
    then
      # @global VAR1,VAR2
      var_names="${BASH_REMATCH[1]}"
      import_multiple_variables "$var_names" "$_from_file"
    # TODO: rename to @uses_funcs?
    elif [[ "$dep_line" =~ \#\ @function\ (.*)$ ]]
    then
      # @function some_func,some_func_2
      func_names="${BASH_REMATCH[1]}"
      import_multiple_functions "$func_names" "$_from_file"
    elif [[ "$dep_line" =~ \#\ @uses_cmds\ (.*)$ ]]
    then
      cmd_names="${BASH_REMATCH[1]}"
      add_cmd_requirements "$cmd_names"
    fi
  done <<< "$func_dependencies"

  # TODO: verify that the function is actually used in the script (as best I can tell), and show a warning if not
}

# add functions (and any dependencies) to imports
import_multiple_functions() {
  # arguments:
  local _func_names="$1"
  local _from_file="$2"

  # split these on comma and/or space
  IFS=', ' read -r -a func_import_names <<< "$_func_names"
  for func_name in "${func_import_names[@]}"
  do
    import_function "$func_name" "$_from_file"
  done
}

add_cmd_requirements() {
  local cmd_names_string="$1"

  # split these on comma and/or space
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

  if need_to_generate "$script_file" "$new_file_name"
  then
    # read file contents
    file_contents=$(<"$script_file")

    # variable and function imports
    declare -A var_imports
    declare -A func_imports
    declare -A cmd_requirements

    # lines from the input script that are not imports
    other_lines=()
    # keep track of the current line number for errors
    current_line=0
    while IFS= read -r line
    do
      current_line=$(( current_line + 1 ))

      if [[ "$line" =~ ^@import_var\ {\ (.*)\ }\ from\ (.*)$ ]]
      then
        # @import { MULTIPLE, VARIABLES } from file
        var_names="${BASH_REMATCH[1]}"
        file_name="${BASH_REMATCH[2]}"
        import_multiple_variables "$var_names" "$file_name"
      elif [[ "$line" =~ ^@import_var\ (.*)\ from\ (.*)$ ]]
      then
        # @import_var VARIABLE from file
        var_name="${BASH_REMATCH[1]}"
        file_name="${BASH_REMATCH[2]}"
        import_variable "$var_name" "$file_name"
      elif [[ "$line" =~ ^@import\ {\ (.*)\ }\ from\ (.*)$ ]]
      then
        # @import { multiple, functions } from file
        func_names="${BASH_REMATCH[1]}"
        file_name="${BASH_REMATCH[2]}"
        import_multiple_functions "$func_names" "$file_name"
      elif [[ "$line" =~ ^@import\ (.*)\ from\ (.*)$ ]]
      then
        # @import function from file
        func_name="${BASH_REMATCH[1]}"
        file_name="${BASH_REMATCH[2]}"
        import_function "$func_name" "$file_name"
      elif [[ "$line" =~ ^@uses_cmds\ (.*)$ ]]
      then
        cmd_names="${BASH_REMATCH[1]}"
        add_cmd_requirements "$cmd_names"
      elif [[ "$line" =~ \?PLATFORM_IS_MAC\? ]]
      then
        replace_test="$(echo "$line" | sed 's/\?PLATFORM_IS_MAC\?/[ "$(uname -s)" == "Darwin" ]/')"
        other_lines+=( "$replace_test" )
      elif [[ "$line" =~ \?PLATFORM_IS_LINUX\? ]]
      then
        replace_test="$(echo "$line" | sed 's/\?PLATFORM_IS_LINUX\?/[ "$(uname -s)" == "Linux" ]/')"
        other_lines+=( "$replace_test" )
      elif [[ "$line" =~ ^(\ *)@EXIT_IF_CMD_ERROR\ \"(.*)\"$ ]]
      then
        # TODO: allow specifying functions to call before exiting
        padding="${BASH_REMATCH[1]}"
        exit_msg="${BASH_REMATCH[2]}"
        exit_with_message gen_code "$exit_msg" "$padding"
        other_lines+=( "$gen_code" )
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

    # write the new file
    echo "$script_file -> $new_file_name"
    echo "$with_header" > "$new_file_name"
    files_generated=$((files_generated+1))

    # clear arrays
    unset var_imports
    unset func_imports
    unset cmd_requirements
  else
    # don't need to generate file
    echo -e "${COLOR_FG_YELLOW}$script_file -> $new_file_name (skipped)${COLOR_RESET}"
    files_skipped=$((files_skipped+1))
  fi

  # make sure the generated script is executable
  chmod +x "$new_file_name"
done

echo ""
echo "generated $files_generated, skipped $files_skipped"

