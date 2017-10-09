#!/usr/bin/env bats

# need to make the functions available
source .bash_aliases


function compare_versions() {
    # these will only be shown if the test fails
    echo "Input version: '$1'" >&2
    echo "Compared with: '$2'" >&2
    echo "    Expecting: '$3'" >&2
    # compare the strings and return the result
    run meets_version $1 $2
    echo "     Received: '$status'" >&2
    echo "       Output: '$output'" >&2
    [ "$status" = "$3" ]
    return
}


@test "Functional | meets_version | bad input version" {
    compare_versions "1.2.pizza" "1.*.*" 1
    expected_output="$(echo -e ${COLOR_FG_RED}bad input version: 1.2.pizza${COLOR_RESET})"
    [ "$output" = "$expected_output" ]
}

@test "Functional | meets_version | bad version constraint 1.2.pizza" {
    compare_versions "1.2.3" "1.2.pizza" 1
    expected_output="$(echo -e ${COLOR_FG_RED}bad version constraint: 1.2.pizza${COLOR_RESET})"
    [ "$output" = "$expected_output" ]
}

@test "Functional | meets_version | bad version constraint 1.*.**" {
    compare_versions "1.2.3" "1.*.**" 1
    expected_output="$(echo -e ${COLOR_FG_RED}bad version constraint: 1.*.**${COLOR_RESET})"
    [ "$output" = "$expected_output" ]
}

@test "Functional | meets_version | bad version constraint *.*.*" {
    compare_versions "1.2.3" "*.*.*" 1
    expected_output="$(echo -e ${COLOR_FG_RED}bad version constraint: *.*.*${COLOR_RESET})"
    [ "$output" = "$expected_output" ]
}

@test "Functional | meets_version | 2.3.4 >= 1.*.* : true" {
    compare_versions "2.3.4" "1.*.*" 0
}

@test "Functional | meets_version | 1.2.12 >= 1.*.* : true" {
    compare_versions "1.2.12" "1.*.*" 0
}

@test "Functional | meets_version | 1.2.12 >= 1.1.* : true" {
    compare_versions "1.2.12" "1.1.*" 0
}

@test "Functional | meets_version | 2.3.4 >= 2.3.* : true" {
    compare_versions "2.3.4" "2.3.*" 0
}

@test "Functional | meets_version | 2.3.4 >= 2.3.2 : true" {
    compare_versions "2.3.4" "2.3.2" 0
}

@test "Functional | meets_version | 2.3.4 >= 2.3.4 : true" {
    compare_versions "2.3.4" "2.3.4" 0
}

@test "Functional | meets_version | 2.3.4 >= 3.*.* : false" {
    compare_versions "2.3.4" "3.*.*" 2
}

@test "Functional | meets_version | 2.3.4 >= 2.4.* : false" {
    compare_versions "2.3.4" "2.4.*" 3
}

@test "Functional | meets_version | 2.3.4 >= 2.3.5 : false" {
    compare_versions "2.3.4" "2.3.5" 4
}
