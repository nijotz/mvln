#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # the directory of the script
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" && pwd )"

    PATH="$DIR/../:$PATH"
}

@test "Test help" {
    mvln -h | grep "Move source files and directories"
}

@test "Test file to file" {
    cd $BATS_TEST_TMPDIR
    touch a
    mvln a b
    [[ -L a && -e a ]]
}

@test "Test file to directory" {
    cd $BATS_TEST_TMPDIR
    touch a
    mkdir z
    mvln a z
    [[ -L a && -e a ]]
}

@test "Test multiple files to a directory" {
    cd $BATS_TEST_TMPDIR
    echo a > a
    echo b > b
    echo c > c
    mkdir z
    mvln a b c z
    grep a z/a
    grep b z/b
    grep c z/c
    [[ -L a && -e a ]]
    [[ -L b && -e b ]]
    [[ -L c && -e c ]]
}

@test "Test directory to directory" {
    cd $BATS_TEST_TMPDIR
    mkdir a
    mkdir z
    mvln a z
    [[ -L a && -e a ]]
}

@test "Test directory to directory with trailing slash on source" {
    cd $BATS_TEST_TMPDIR
    mkdir a
    mkdir z
    mvln a/ z
    [[ -L a && -e a ]]
}
