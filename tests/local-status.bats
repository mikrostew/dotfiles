#!/usr/bin/env bats

source .bash_repo_status

tmpdirname="$TMPDIR/tmp$RANDOM"
base_str="  $GS_COLOR_GIT$GS_SYM_GIT$COLOR_RESET$GS_SYM_BRANCH${GS_COLOR_BRANCH}master$COLOR_RESET $GS_COLOR_NO_REMOTE$GS_SYM_NO_REMOTE$COLOR_RESET / "

setup() {
    mkdir "$tmpdirname"
    cd "$tmpdirname"
    git init
}
teardown() {
    cd ..
    rm -rf "$tmpdirname"
}

@test "local status | untracked file - should return success" {
    touch "newfile.txt"
    run repo_status
    [ "$status" -eq 0 ]
}

@test "local status | untracked file - should return correct status line" {
    touch "newfile.txt"
    run repo_status
    expected="$(echo -e "$base_str${GS_COLOR_UNTRACKED}1$COLOR_RESET$GS_SYM_UNTRACKED")"
    echo "'${lines[0]}' != '$expected'" >&2
    echo "$(cmp -bl <(echo "${lines[0]}") <(echo "$expected") )" >&2
    [ "${lines[0]}" = "$expected" ]
}

@test "local status | staged file - should return success" {
    run touch "newfile.txt"
    [ "$status" -eq 0 ]
    git add "newfile.txt"
    run repo_status
    [ "$status" -eq 0 ]
}

@test "local status | staged file - should return correct status line" {
    touch "newfile.txt"
    git add "newfile.txt"
    run repo_status
    expected="$(echo -e "$base_str${GS_COLOR_STAGED}1$COLOR_RESET$GS_SYM_STAGED")"
    echo "'${lines[0]}' != '$expected'" >&2
    echo "$(cmp -bl <(echo "${lines[0]}") <(echo "$expected") )" >&2
    [ "${lines[0]}" = "$expected" ]
}

