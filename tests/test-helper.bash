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

# Compare the input strings and return the result. If strings differ, difference will be shown.
# arguments:
#  $1 - the expected string
#  $2 - the actual string
compare_status_strings() {
    # these will only be shown if the test fails
    echo -e "Expected:$COLOR_RESET '$1'" >&2
    echo -e "  Actual:$COLOR_RESET '$2'" >&2
    echo "$(cmp -bl <(echo "$1") <(echo "$2") )" >&2
    # compare the strings and return the result
    [ "$1" = "$2" ]
    return
}

# Compare the full status string to the expected
# arguments:
#  $1 - the expected status line
compare_full_status() {
    local expected="$(echo -e "$1")"
    local actual="${lines[0]}"
    $(compare_status_strings "$expected" "$actual")
    return
}

# Remove all but the local status from the output line, and compare to expected
# arguments:
#  $1 - the expected status line
compare_local_status() {
    local expected="$(echo -e "$1")"
    local actual="$(echo "${lines[0]}" | sed -e 's|.*/ ||')"
    $(compare_status_strings "$expected" "$actual")
    return
}

# Remove all but the remote status from the output line, and compare to expected
# arguments:
#  $1 - the expected status line
compare_remote_status() {
    local expected="$(echo -e "$1")"
    local actual="$(echo "${lines[0]}" | sed -e 's|[^ ]* ||' -e 's| /.*$||')"
    $(compare_status_strings "$expected" "$actual")
    return
}

# common format strings used in the tests
test_git_str="$GS_COLOR_GIT$GS_SYM_GIT$COLOR_RESET"
test_master_branch_str="$GS_SYM_BRANCH${GS_COLOR_BRANCH}master$COLOR_RESET"
test_no_remote_str="$GS_COLOR_NO_REMOTE$GS_SYM_NO_REMOTE$COLOR_RESET"
test_commit_no_remote_str="${GS_COLOR_NEED_PUSH_UNTRACKED}1$COLOR_RESET$GS_SYM_NEED_PUSH_UNTRACKED"
test_local_ok_str="$GS_COLOR_LOCAL_OK$GS_SYM_LOCAL_OK$COLOR_RESET"
test_untracked_file_str="${GS_COLOR_UNTRACKED}1$COLOR_RESET$GS_SYM_UNTRACKED"
test_staged_file_str="${GS_COLOR_STAGED}1$COLOR_RESET$GS_SYM_STAGED"
test_modified_file_str="${GS_COLOR_MODIFIED}1$COLOR_RESET$GS_SYM_MODIFIED"
