#!/usr/bin/env bats

source .bash_repo_status

tmpdirname="tmp$RANDOM"

setup() {
    mkdir "$tmpdirname"
    cd "$tmpdirname"
    git init
}
teardown() {
    cd ..
    rm -r "$tmpdirname"
}

@test "it should return success" {
    run repo_status
    echo "$status" >&2
    [ "$status" -eq 0 ]
}

@test "it should recognize this as a git repo" {
    run repo_status
    echo "${lines[0]}" >&2
    [[ "${lines[0]}" =~ "git" ]]
}


