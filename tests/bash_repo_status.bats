#!/usr/bin/env bats

# need to make the functions available
source .bash_repo_status

load test-helper


# full status

@test "Functional | full status | empty repo" {
    run repo_status
    [ "$status" -eq 0 ]
    compare_status "$test_git_str$test_master_branch_str $test_no_remote_str / $test_local_ok_str"
}

@test "Functional | full status | 1 commit no remote" {
    touch "newfile.txt"
    git add  "newfile.txt"
    git commit -m "Test commit"

    run repo_status
    [ "$status" -eq 0 ]
    compare_status "$test_git_str$test_master_branch_str $test_commit_no_remote_str / $test_local_ok_str"
}

# parse branch line

@test "Functional | parse branch line | empty repo" {
    run test_parse_branch_line
    [ "$status" -eq 0 ]
    compare_status "No commits yet on master"
}

@test "Functional | parse branch line | one commit" {
    touch "newfile.txt"
    git add  "newfile.txt"
    git commit -m "First commit"

    run test_parse_branch_line
    [ "$status" -eq 0 ]
    compare_status "master"
}

@test "Functional | parse branch line | checkout hash" {
    touch "newfile.txt"
    git add  "newfile.txt"
    git commit -m "First commit"
    touch "newfile2.txt"
    git add  "newfile2.txt"
    git commit -m "Second commit"
    git checkout HEAD~1

    run test_parse_branch_line
    [ "$status" -eq 0 ]
    compare_status "HEAD (no branch)"
}

@test "Functional | parse branch line | checkout tag" {
    touch "newfile.txt"
    git add  "newfile.txt"
    git commit -m "First commit"
    git tag "v1.0"
    touch "newfile2.txt"
    git add  "newfile2.txt"
    git commit -m "Second commit"
    git checkout "v1.0"

    run test_parse_branch_line
    [ "$status" -eq 0 ]
    compare_status "HEAD (no branch)"
}

# parse head and origin

@test "Functional | parse head and origin | empty repo" {
    run test_git_head_origin_head
    [ "$status" -eq 0 ]
    compare_status "${GS_SYM_BRANCH}${GS_COLOR_BRANCH}master${COLOR_RESET}"

    run test_git_head_origin_head_nocolor
    [ "$status" -eq 0 ]
    compare_status "master"

    run test_git_head_origin_origin
    [ "$status" -eq 0 ]
    compare_status ""
}

@test "Functional | parse head and origin | empty repo, with remote" {
    rm -rf .git/
    git clone git@github.com:mikrostew/empty-repo-for-testing.git ./

    run test_git_head_origin_head
    [ "$status" -eq 0 ]
    compare_status "${GS_SYM_BRANCH}${GS_COLOR_BRANCH}master${COLOR_RESET}"

    run test_git_head_origin_head_nocolor
    [ "$status" -eq 0 ]
    compare_status "master"

    run test_git_head_origin_origin
    [ "$status" -eq 0 ]
    compare_status "origin/master"
}


@test "Functional | parse head and origin | checkout hash" {
    touch "newfile.txt"
    git add  "newfile.txt"
    git commit -m "First commit"
    touch "newfile2.txt"
    git add  "newfile2.txt"
    git commit -m "Second commit"
    git checkout HEAD~1

    local expected_hash="$(git rev-parse --short HEAD)"

    run test_git_head_origin_head
    [ "$status" -eq 0 ]
    compare_status "${GS_SYM_HASH}${GS_COLOR_BRANCH}$expected_hash${COLOR_RESET}"

    run test_git_head_origin_head_nocolor
    [ "$status" -eq 0 ]
    compare_status ""

    run test_git_head_origin_origin
    [ "$status" -eq 0 ]
    compare_status ""
}

@test "Functional | parse head and origin | checkout tag" {
    touch "newfile.txt"
    git add  "newfile.txt"
    git commit -m "First commit"
    git tag "v1.0"
    touch "newfile2.txt"
    git add  "newfile2.txt"
    git commit -m "Second commit"
    git checkout "v1.0"

    run test_git_head_origin_head
    [ "$status" -eq 0 ]
    compare_status "${GS_SYM_TAG}${GS_COLOR_BRANCH}v1.0${COLOR_RESET}"

    run test_git_head_origin_head_nocolor
    [ "$status" -eq 0 ]
    compare_status ""

    run test_git_head_origin_origin
    [ "$status" -eq 0 ]
    compare_status ""
}

# local status

@test "Functional | local status | untracked file" {
    touch "newfile.txt"

    run test_git_local_status
    [ "$status" -eq 0 ]
    compare_status "$test_untracked_file_str"
}

@test "Functional | local status | staged file" {
    touch "newfile.txt"
    git add "newfile.txt"

    run test_git_local_status
    [ "$status" -eq 0 ]
    compare_status "$test_staged_file_str"
}

@test "Functional | local status | modified file" {
    touch "newfile.txt"
    git add -N "newfile.txt"

    run test_git_local_status
    [ "$status" -eq 0 ]
    compare_status "$test_modified_file_str"
}

# remote status

@test "Functional | remote status | empty repo" {
    run repo_status
    [ "$status" -eq 0 ]
    compare_remote_status "$test_no_remote_str"
}

@test "Functional | remote status | 1 commit, no remote" {
    touch "newfile.txt"
    git add  "newfile.txt"
    git commit -m "Test commit"

    run repo_status
    [ "$status" -eq 0 ]
    compare_remote_status "$test_commit_no_remote_str"
}
