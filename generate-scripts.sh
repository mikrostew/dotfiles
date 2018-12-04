#!/usr/bin/env bash
# This will process the script definitions in script-gen/ and convert those
# into executable scripts in scripts/

COLOR_RESET='\033[0m'
COLOR_FG_BOLD_YELLOW='\033[1;33m'
COLOR_FG_GREEN='\033[0;32m'
COLOR_FG_RED='\033[0;31m'

declare -A sourced_files
# keep track of hashes for dependent files (and only calculate once)
declare -A dep_file_hashes

files_generated=0
files_skipped=0

# echo to stderr with red text
echo_err() {
  echo -en "\n${COLOR_FG_RED}$@${COLOR_RESET} " >&2
}
# echo warning to stderr with yellow text
echo_warn() {
  echo -en "\n${COLOR_FG_BOLD_YELLOW}Warning: $@${COLOR_RESET} " >&2
}

on_error() {
  exit_code="$?"
  # not all errors will come from lines in files, fix that if it becomes an issue
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
  if [ ! -f "$generated_script" ]; then return 0; fi

  # get hashfrom last file generation
  readarray -t -s5 -n1 hash_lines < "$generated_script"
  # remove the leading hash
  local prev_hash="${hash_lines[0]#\#}"

  # for the generated script, skip the header (which contains the calculated hash) and is currently 7 lines long
  local combined_hash
  hash_for_scripts combined_hash "$src_script" "$(tail -n +8 $generated_script)"

  # if hash matches, no need to regenerate
  if [ "$combined_hash" == "$prev_hash" ]
  then
    return 1
  fi

  # otherwise have to generate
  return 0
}

dependency_hashes() {
  # arguments:
  local varname="$1"
  local for_script="$2"

  # read script contents
  local contents=$(<"$for_script")

  local import_hashes=""

  # variable and function imports
  unset script_dependencies
  declare -A script_dependencies

  while IFS= read -r line
  do
    if [[ "$line" =~ ^@import\ .*\ from\ (.*)$ ]]
    then
      depends_on_file="${BASH_REMATCH[1]}"
      script_dependencies[$depends_on_file]='file'
    elif [[ "$line" =~ ^@import_var\ .*\ from\ (.*)$ ]]
    then
      depends_on_file="${BASH_REMATCH[1]}"
      script_dependencies[$depends_on_file]='var'
    fi
  done <<< "$contents"

  # get hashes for dependencies
  for dep in "${!script_dependencies[@]}"
  do
    local already_hashed="${dep_file_hashes[$dep]:-noexist}"
    if [ "$already_hashed" == "noexist" ]
    then
      # haven't hashed dep yet
      local dep_hash="$(md5 -q $dep)"
      dep_file_hashes[$dep]="$dep_hash"
      import_hashes+="$dep_hash"
    else
      import_hashes+="$already_hashed"
    fi
  done

  printf -v "$varname" "$import_hashes"
}

# calculate the hash of the src and dest scripts
hash_for_scripts() {
  # arguments:
  local varname="$1"
  local src_file="$2"
  local generated_contents="$3"

  # get hashes of dependencies
  local dep_hashes
  dependency_hashes dep_hashes "$src_file"

  # combine everything and calculate the hash
  # - using md5 because I want this to be fast and I'm not worried about collisions
  local full_hash="$(echo "${generated_contents}${dep_hashes}" | cat "$src_file" - | md5 -q)"
  printf -v "$varname" "$full_hash"
}

# create a header for the generated script file
file_header() {
  # arguments:
  local varname="$1"
  local input_file="$2"
  local file_contents="$3"

  # calculate the hash
  local combined_hash
  hash_for_scripts combined_hash "$input_file" "$file_contents"

  local header_contents=""
  header_contents+="#!/usr/bin/env bash\n"
  header_contents+="###########################################################################\n"
  header_contents+="# DO NOT EDIT! This script was auto-generated. To update this script, edit\n"
  header_contents+="# the file $input_file, and run './generate-scripts.sh'\n"
  header_contents+="###########################################################################\n"
  header_contents+="#$combined_hash\n"
  header_contents+="\n"

  printf -v "$varname" "${header_contents}%s" "$file_contents"
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

print_function() {
  local func_text="$(type "$1")"
  exit_code="$?"
  if [ "$exit_code" -ne 0 ]
  then
    echo_err "Error when trying to print function '$1'"
    exit $exit_code
  fi

  # check that this is a function
  if [[ "$func_text" =~ $1\ is\ a\ function ]]
  then
    echo "$func_text" | sed -e "/^$1 is a function/d;" -e 's/[[:space:]]*$//'
  else
    echo_err "'$1' is not a function"
    exit 1
  fi

}

# add variable to imports
import_variable() {
  # arguments:
  local var_name="$1"
  local from_file="$2"
  local type="$3" # explicit imports will set this to 'explicit'

  # don't re-source files that have already been sourced
  if [ -n "$from_file" ] && [ "${sourced_files[$from_file]}" != "yes" ]
  then
    source "$from_file"
    sourced_files[$from_file]='yes'
  fi

  local var_value="${!var_name}"

  # add to variable import arrays
  add_var_to_imports "$var_name" "$var_value"
  if [ "$type" == "explicit" ]
  then
    explicit_imports[$var_name]='var'
  fi
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
  # if this is an explicit import = $3 - just pass this thru

  # split these on comma and/or space
  IFS=', ' read -r -a var_import_names <<< "$_var_names"
  for var_name in "${var_import_names[@]}"
  do
    import_variable "$var_name" "$_from_file" "$3"
  done
}

full_file_path() {
  if [[ $1 == /* ]] # absolute path
  then
    echo "$1"
  else
    echo "$PWD/$1" # may need readlink here
  fi
}


get_sourced_files() {
  local _from_file="$1"
  local _dep_file_arr=()

  sourced_files="$(grep "^source " "$_from_file" | sed 's/^source //g')"
  if [ -n "$sourced_files" ]
  then
    for _file in $sourced_files
    do
      local full_dep_path="$(eval echo $_file)"
      _dep_file_arr+=( "$full_dep_path" )
      dep_sources=( $(get_sourced_files "$full_dep_path") )
      _dep_file_arr+=( "${dep_sources[@]}" )
    done
  fi

  echo "${_dep_file_arr[@]}"
}

# add function (and any dependencies) to imports
import_function() {
  # arguments:
  local _func_name="$1"
  local _from_file="$(full_file_path "$2")"
  local type="$3" # explicit imports will set this to 'explicit'

  # don't re-source files that have already been sourced
  if [ "${sourced_files[$_from_file]}" != "yes" ]
  then
    source "$_from_file"
    sourced_files[$_from_file]='yes'
  fi

  if [ "$type" == "explicit" ]
  then
    explicit_imports[$_func_name]='func'
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
  dep_files=( "$_from_file" $(get_sourced_files "$_from_file") )

  # also import dependencies of the function
  # right now this is at most 3 lines past the function declaration
  func_dependencies="$(grep -A3 "^${_func_name}()" "${dep_files[@]}")"
  # whatever, just do this inline for now...
  while IFS= read -r dep_line
  do
    if [[ "$dep_line" =~ \#\ @uses_vars\ (.*)$ ]]
    then
      # @uses_vars VAR1,VAR2
      var_names="${BASH_REMATCH[1]}"
      import_multiple_variables "$var_names" "$_from_file"
    elif [[ "$dep_line" =~ \#\ @uses_funcs\ (.*)$ ]]
    then
      # @uses_funcs some_func,some_func_2
      func_names="${BASH_REMATCH[1]}"
      import_multiple_functions "$func_names" "$_from_file"
    elif [[ "$dep_line" =~ \#\ @uses_cmds\ (.*)$ ]]
    then
      cmd_names="${BASH_REMATCH[1]}"
      add_cmd_requirements "$cmd_names"
    fi
  done <<< "$func_dependencies"
}

# add functions (and any dependencies) to imports
import_multiple_functions() {
  # arguments:
  local _func_names="$1"
  local _from_file="$2"
  # if this is an explicit import = $3 - just pass this thru

  # split these on comma and/or space
  IFS=', ' read -r -a func_import_names <<< "$_func_names"
  for func_name in "${func_import_names[@]}"
  do
    import_function "$func_name" "$_from_file" "$3"
  done
}

add_cmd_requirements() {
  local cmd_names_string="$1"

  # split these on comma and/or space
  IFS=', ' read -r -a cmd_names_array <<< "$cmd_names_string"
  for cmd_name in "${cmd_names_array[@]}"
  do
    # TODO: provide better help info on how to install specific things
    how_to_install="search 'how to install $cmd_name'"
    # add command to requirements for the script
    cmd_requirements[$cmd_name]="$how_to_install"
  done
  # and include functions needed for requirement checking
  import_function "requirement_check" "$PWD/.bash_shared_functions" ""
}

add_argument() {
  # arguments:
  local arg_type="$1" # optional|required
  local arg_info_string="$2"

  # split up the strings, preserving spaces inside the quotes (see https://superuser.com/a/1066541)
  local argument_options="$(eval "for arg in $arg_info_string; do echo \$arg; done")"

  readarray -t argument_options <<< "$argument_options"

  local num_arg_options="${#argument_options[@]}"
  if [ "$num_arg_options" -eq 3 ]
  then
    add_flag_arg "${argument_options[0]}" "${argument_options[1]}" "${argument_options[2]}" "$arg_type"
  elif [ "$num_arg_options" -eq 2 ]
  then
    add_noflag_arg "${argument_options[0]}" "${argument_options[1]}" "$arg_type"
  else
    echo_err "Error: Wrong number of arguments"
    on_error
  fi
}

# add an argument that uses a flag
add_flag_arg() {
  # arguments:
  local arg_flag="$1"
  local arg_var_name="$2"
  local arg_help_text="$3"
  local arg_type="$4" # optional|required

  echo_err "add_flag_arg: TODO for now..."

  # TODO: add to help_text_args[]

  if [ "${#arg_flag}" -eq 1 ]
  then
    # true/false flag
    pre_getopt_lines+=( "$arg_var_name='false'" )
    getopts_lines+=( )
    getopts_lines+=( "    $arg_flag)" )
    getopts_lines+=( "      $arg_var_name='true'" )
    getopts_lines+=( "      ;;" )
  elif [ "${#arg_flag}" -eq 2 ] && [ "${arg_flag:1:2}" == ":" ]
  then
    # arg with parameter
    getopts_lines+=( )
    getopts_lines+=( "    ${arg_flag:0:1})" ) # just the flag char, not including the ':'
    getopts_lines+=( "      $arg_var_name=\"\$OPTARG\"" )
    getopts_lines+=( "      ;;" )
  else
    echo_err "Error: Bad flag format '$arg_flag'"
    on_error
  fi
  getopts_argstring+="$arg_flag"

  # and include functions needed for getopts stuff
  import_function "echo_err" "$PWD/.bash_shared_functions" ""
}

# add an argument that does not use a flag
add_noflag_arg() {
  # arguments:
  local arg_var_name="$1"
  local arg_help_text="$2"
  local arg_type="$3" # optional|required

  echo_err "add_noflag_arg: TODO for now..."

  # TODO: add to help_text_args[]

  (( num_remaining_args++ ))
  remaining_arg_lines+=( "$arg_var_name=\"\${$num_remaining_args:?Missing argument '$arg_var_name'}\"" )
}

# read all the files in script-gen/
# (assuming this is run from the base dir of this repo)
for script_file in script-gen/*
do
  # this is where the file will be output
  new_file_name="${script_file/script-gen/scripts}"

  echo -n "$script_file -> $new_file_name..."

  if need_to_generate "$script_file" "$new_file_name"
  then
    # read file contents
    file_contents=$(<"$script_file")

    # variable and function imports
    declare -A var_imports
    declare -A func_imports
    declare -A cmd_requirements
    # keep track of explicit imports to track if they are used
    declare -A explicit_imports

    # lines from the input script that are not imports
    other_lines=()
    # keep track of the current line number for errors
    current_line=0
    # keep track of help text description
    help_text_args=()

    # keep track of arg things for parsing with getopts and such
    getopts_setup_lines=()
    getopts_lines=()
    getopts_argstring=":" # start with colon to disable auto-erroring from getopts
    # and the rest of the arguments
    num_remaining_args=0
    remaining_arg_lines=()

    while IFS= read -r line
    do
      current_line=$(( current_line + 1 ))

      if [[ "$line" =~ ^@import_var\ {\ (.*)\ }\ from\ (.*)$ ]]
      then
        # @import_var { MULTIPLE, VARIABLES } from file
        var_names="${BASH_REMATCH[1]}"
        file_name="${BASH_REMATCH[2]}"
        import_multiple_variables "$var_names" "$file_name" "explicit"
      elif [[ "$line" =~ ^@import_var\ (.*)\ from\ (.*)$ ]]
      then
        # @import_var VARIABLE from file
        var_name="${BASH_REMATCH[1]}"
        file_name="${BASH_REMATCH[2]}"
        import_variable "$var_name" "$file_name" "explicit"
      elif [[ "$line" =~ ^@import\ {\ (.*)\ }\ from\ (.*)$ ]]
      then
        # @import { multiple, functions } from file
        func_names="${BASH_REMATCH[1]}"
        file_name="${BASH_REMATCH[2]}"
        import_multiple_functions "$func_names" "$file_name" "explicit"
      elif [[ "$line" =~ ^@import\ (.*)\ from\ (.*)$ ]]
      then
        # @import function from file
        func_name="${BASH_REMATCH[1]}"
        file_name="${BASH_REMATCH[2]}"
        import_function "$func_name" "$file_name" "explicit"
      elif [[ "$line" =~ ^@uses_cmds\ (.*)$ ]]
      then
        cmd_names="${BASH_REMATCH[1]}"
        add_cmd_requirements "$cmd_names"
      elif [[ "$line" =~ ^@arg\ (.*)$ ]]
      then
        arg_info="${BASH_REMATCH[1]}"
        add_argument 'required' "$arg_info"
      elif [[ "$line" =~ ^@arg_optional\ (.*)$ ]]
      then
        optional_arg_info="${BASH_REMATCH[1]}"
        add_argument 'optional' "$optional_arg_info"
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

    # verify that the function & variable imports are actually used in the script (as best I can tell)
    for import_name in "${!explicit_imports[@]}"
    do
      found_import='false'
      for orig_line in "${other_lines[@]}"
      do
        if [ -n "$orig_line" ] && [[ ! "$orig_line" =~ ^\ *\# ]]
        then
          # this is not a comment or blank line
          if [ "${explicit_imports[$import_name]}" == "var" ]
          then
            if [[ "$orig_line" =~ \$$import_name ]] || [[ "$orig_line" =~ \${$import_name} ]]
            then
              found_import='true'
              break
            fi
          elif [ "${explicit_imports[$import_name]}" == "func" ]
          then
            if [[ "$orig_line" =~ $import_name ]] # just check that the function name appears somewhere
            then
              found_import='true'
              break
            fi
          fi
        fi
      done
      if [ "$found_import" == "false" ]
      then
        echo_warn "Unused import '$import_name'"
      fi
    done

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
      # add the checks for command requirements
      cmd_requirement_lines+=( 'combined_return=0' )
      for cmd_name in "${!cmd_requirements[@]}"
      do
        how_to_install="${cmd_requirements[$cmd_name]}"
        # platform-specific commands
        if [[ "$cmd_name" =~ (.*)/(.*) ]]
        then
          actual_command="${BASH_REMATCH[1]}"
          os_for_cmd="${BASH_REMATCH[2]}"
          if [ "$os_for_cmd" == "OSX" ]
          then
            # TODO: combine multiple of these under one check
            cmd_requirement_lines+=( 'if [ "$(uname -s)" == "Darwin" ]; then' )
            cmd_requirement_lines+=( "  requirement_check $actual_command \"$how_to_install\"" )
            cmd_requirement_lines+=( '  combined_return=$(( combined_return + $? ))' )
            cmd_requirement_lines+=( 'fi' )
          elif [ "$os_for_cmd" == "Linux" ]
          then
            # TODO: combine multiple of these under one check
            cmd_requirement_lines+=( 'if [ "$(uname -s)" == "Linux" ]; then' )
            cmd_requirement_lines+=( "  requirement_check $actual_command \"$how_to_install\"" )
            cmd_requirement_lines+=( '  combined_return=$(( combined_return + $? ))' )
            cmd_requirement_lines+=( 'fi' )
          fi
        else
          # platform-agnostic
          cmd_requirement_lines+=( "requirement_check $cmd_name \"$how_to_install\"" )
          cmd_requirement_lines+=( 'combined_return=$(( combined_return + $? ))' )
        fi
      done
      cmd_requirement_lines+=( 'if [ "$combined_return" != 0 ]; then exit $combined_return; fi' )
    fi

    # build getopts parsing
    # TODO: if no getopts required, don't do this

    # before the args that were added
    getopts_setup_lines+=( "while getopts \"$getopts_argstring\" opt" )
    getopts_setup_lines+=( 'do' )
    getopts_setup_lines+=( '  case $opt in' )

    # after the other args that were added
    # TODO: also need this when generating the help text
    # getopts_lines+=( '    h)' )
    # getopts_lines+=( '      show_help_msg' )
    # getopts_lines+=( '      exit 0' )
    getopts_lines+=( '    \?)' )
    getopts_lines+=( "      echo_err \"\$0: Invalid option '-\$OPTARG'\"" )
    getopts_lines+=( '      exit 1' )
    getopts_lines+=( '      ;;' )
    getopts_lines+=( '    :)' )
    getopts_lines+=( "      echo_err \"\$0: Option '-\$OPTARG' requires an argument\"" )
    getopts_lines+=( '      exit 1' )
    getopts_lines+=( '      ;;' )
    getopts_lines+=( '  esac' )
    getopts_lines+=( 'done' )
    # get rid of any positional params
    getopts_lines+=( 'shift $((OPTIND-1))' )


    # TODO: generate some help text like so
    # Usage:
    #  spinner [-m spin_msg] cmd_pid
    # and some help docs
    # show_help_msg() {
    #   echo 'blah blah'
    # }

    # join imports and other lines (joined with newlines)
    with_imports="$(
      IFS=$'\n';
      echo "${var_import_lines[*]}";
      echo "${func_import_lines[*]}";
      echo "${getopts_setup_lines[*]}";
      echo "${getopts_lines[*]}";
      echo "${cmd_requirement_lines[*]}";
      echo "${remaining_arg_lines[*]}";
      echo "${other_lines[*]}";
    )"

    # strip any comments and blank lines
    # (I may not wont to do this eventually - to add comments for readability)
    no_comments="$(echo "$with_imports" | sed '/^[[:blank:]]*#/d;/^[[:blank:]]*$/d;')"

    # add a header and shebang to the beginning
    with_header=""
    file_header with_header "$script_file" "$no_comments"

    # write the new file
    echo "$with_header" > "$new_file_name"
    echo -e "[${COLOR_FG_GREEN}OK${COLOR_RESET}]"
    files_generated=$(( files_generated+1 ))

    # clear arrays
    unset var_imports
    unset func_imports
    unset cmd_requirements
    unset explicit_imports
  else
    # don't need to generate file
    echo -e "[${COLOR_FG_BOLD_YELLOW}skip${COLOR_RESET}]"
    files_skipped=$(( files_skipped+1 ))
  fi

  # make sure the generated script is executable
  chmod +x "$new_file_name"
done

echo ""
echo "generated $files_generated, skip $files_skipped"

