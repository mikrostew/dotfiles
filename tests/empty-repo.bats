#!/usr/bin/env bats

load test-helper

@test "empty repo | should return success" {
    run repo_status
    [ "$status" -eq 0 ]
}

@test "empty repo | should return the correct status line" {
    run repo_status
    compare_status_line "$test_localstat_base_str$test_local_ok_str"
}

