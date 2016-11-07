#!/usr/bin/env bats

load test-helper

@test "remote status | empty initial repo - should return success" {
    run repo_status
    [ "$status" -eq 0 ]
}

@test "remote status | empty initial repo - should return correct status line" {
    run repo_status
    compare_remote_status "$test_no_remote_str"
}

