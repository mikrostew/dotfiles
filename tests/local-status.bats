#!/usr/bin/env bats

load test-helper

@test "local status | untracked file - should return success" {
    touch "newfile.txt"
    run repo_status
    [ "$status" -eq 0 ]
}

@test "local status | untracked file - should return correct status line" {
    touch "newfile.txt"
    run repo_status
    compare_local_status "$test_untracked_file_str"
}

@test "local status | staged file - should return success" {
    touch "newfile.txt"
    git add "newfile.txt"
    run repo_status
    [ "$status" -eq 0 ]
}

@test "local status | staged file - should return correct status line" {
    touch "newfile.txt"
    git add "newfile.txt"
    run repo_status
    compare_local_status "$test_staged_file_str"
}

@test "local status | modified file - should return success" {
    touch "newfile.txt"
    git add -N "newfile.txt"
    run repo_status
    [ "$status" -eq 0 ]
}

@test "local status | modified file - should return correct status line" {
    touch "newfile.txt"
    git add -N "newfile.txt"
    run repo_status
    compare_local_status "$test_staged_file_str $test_modified_file_str"
}

