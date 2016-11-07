#!/usr/bin/env bats

load test-helper


# empty repo

@test "Functional | full status | empty repo" {
    run repo_status
    [ "$status" -eq 0 ]
    compare_full_status "  $test_git_str$test_master_branch_str $test_no_remote_str / $test_local_ok_str"
}

# local status

@test "Functional | local status | untracked file" {
    touch "newfile.txt"
    run repo_status
    [ "$status" -eq 0 ]
    compare_local_status "$test_untracked_file_str"
}

@test "Functional | local status | staged file" {
    touch "newfile.txt"
    git add "newfile.txt"
    run repo_status
    [ "$status" -eq 0 ]
    compare_local_status "$test_staged_file_str"
}

@test "Functional | local status | modified file" {
    touch "newfile.txt"
    git add -N "newfile.txt"
    run repo_status
    [ "$status" -eq 0 ]
    compare_local_status "$test_staged_file_str $test_modified_file_str"
}

# remote status

@test "Functional | remote status | empty repo" {
    run repo_status
    [ "$status" -eq 0 ]
    compare_remote_status "$test_no_remote_str"
}

