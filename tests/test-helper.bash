# shared testing code

# need to make the functions available
source .bash_repo_status

# create test repos in tmp directories
tmpdirname="$TMPDIR/tmp$RANDOM"

# for every test, initialize an empty repo, and cleanup after
setup() {
    mkdir "$tmpdirname"
    cd "$tmpdirname"
    git init
}
teardown() {
    cd ..
    rm -rf "$tmpdirname"
}

# compare output to the expected status line
# $1 - the expected status line
compare_status_line() {
    local expected="$(echo -e "$1")"
    # these will only be shown if the test fails
    echo "Expected: $expected" >&2
    echo "  Actual: ${lines[0]}" >&2
    echo "$(cmp -bl <(echo "${lines[0]}") <(echo "$expected") )" >&2
    # compare the strings and return the result
    [ "${lines[0]}" = "$expected" ]
    return
}

# common format strings used in the tests
test_git_str="$GS_COLOR_GIT$GS_SYM_GIT$COLOR_RESET"
test_master_branch_str="$GS_SYM_BRANCH${GS_COLOR_BRANCH}master$COLOR_RESET"
test_no_remote_str="$GS_COLOR_NO_REMOTE$GS_SYM_NO_REMOTE$COLOR_RESET"
test_local_ok_str="$GS_COLOR_LOCAL_OK$GS_SYM_LOCAL_OK$COLOR_RESET"
test_untracked_file_str="${GS_COLOR_UNTRACKED}1$COLOR_RESET$GS_SYM_UNTRACKED"
test_staged_file_str="${GS_COLOR_STAGED}1$COLOR_RESET$GS_SYM_STAGED"
test_modified_file_str="${GS_COLOR_MODIFIED}1$COLOR_RESET$GS_SYM_MODIFIED"

test_localstat_base_str="  $test_git_str$test_master_branch_str $test_no_remote_str / "
