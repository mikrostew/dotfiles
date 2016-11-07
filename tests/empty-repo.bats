#!/usr/bin/env bats

source .bash_repo_status

tmpdirname="$TMPDIR/tmp$RANDOM"

setup() {
    mkdir "$tmpdirname"
    cd "$tmpdirname"
    git init
}
teardown() {
    cd ..
    rm -rf "$tmpdirname"
}

@test "empty repo | should return success" {
    run repo_status
    echo "$status" >&2
    [ "$status" -eq 0 ]
}

@test "empty repo | should return the correct status line" {
    run repo_status
    expected="$(echo -e "  $GS_COLOR_GIT$GS_SYM_GIT$COLOR_RESET$GS_SYM_BRANCH${GS_COLOR_BRANCH}master$COLOR_RESET $GS_COLOR_NO_REMOTE$GS_SYM_NO_REMOTE$COLOR_RESET / $GS_COLOR_LOCAL_OK$GS_SYM_LOCAL_OK$COLOR_RESET")"
    echo "'${lines[0]}' != '$expected'" >&2
    echo "$(cmp -bl <(echo "${lines[0]}") <(echo "$expected") )" >&2
    [ "${lines[0]}" = "$expected" ]
}

