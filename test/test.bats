#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    # the directory of this test script
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" && pwd )"

    # Add the root path of this repo to the PATH for mvln to work below
    PATH="$DIR/../:$PATH"
}

@test "Test help" {
    mvln -h | grep "Move source files and directories"
}

@test "Test invalid option" {
    run mvln -6
    [ "$status" = 16 ]
    [[ "$output" =~ "illegal option -- 6" ]]
}

@test "Test requirements missing" {
    # Keep track of the srcdir to add it to the path
    srcdir=$(pwd)
    cd $BATS_TEST_TMPDIR

    # Remove access to all binaries
    mkdir bin
    ## Needed by bats
    ln -s $(which rm) bin/rm
    ## Needed by this test
    ln -s $(which touch) bin/touch
    ln -s $(which which) bin/which
    ln -s $(which chmod) bin/chmod
    ## Needed by mvln
    ln -s $(which dirname) bin/dirname
    ln -s $(which ln) bin/ln
    ln -s $(which mv) bin/mv
    ### Break a requirement
    ln -s $(which realpath) bin/not-realpath

    # Test requirement missing
    PATH="$srcdir:./bin"
    touch a
    run mvln a b
    [ "$status" -ne 0 ]
    [ "${lines[0]}" = "ERROR: Required: realpath" ]
    [ "${lines[1]}" = "ERROR: One or more executables or apps are missing." ]
    ## Verify nothing changed
    [[ -f a && ! -e b ]]

    # Test requirement existing works
    mv bin/not-realpath bin/realpath
    run mvln a b
    [ "$status" = 0 ]
    [[ -L a && -e a ]]
}

@test "Test realpath requirement has wrong version" {
    # Fake a bad realpath
    cd $BATS_TEST_TMPDIR
    mkdir bin
    touch bin/realpath
    chmod +x bin/realpath

    # Test bad requirement
    PATH="./bin:$PATH"
    touch a
    run mvln a b
    [ "$status" -ne 0 ]
    [ "$output" = "ERROR: GNU version of realpath required" ]

    # Verify nothing changed
    [[ -f a && ! -e b ]]
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
    grep a a
    grep b b
    grep c c
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
    echo b > a/b
    mkdir z
    mvln a z
    grep b a/b
    grep b z/a/b
    [[ -L a && -e a ]]
}

@test "Test directory to directory, with renaming" {
    cd $BATS_TEST_TMPDIR
    mkdir a
    echo b > a/b
    mkdir z
    mvln a z/y
    grep b a/b
    grep b z/y/b
    [[ -L a && -e a ]]
}

@test "Test directory to directory, with trailing slashes" {
    cd $BATS_TEST_TMPDIR
    mkdir a
    echo b > a/b
    mkdir z
    mvln a/ z/
    grep b a/b
    grep b z/a/b
    [[ -L a && -e a ]]
}

@test "Test directory to directory, with trailing slash on source" {
    cd $BATS_TEST_TMPDIR
    mkdir a
    echo b > a/b
    mkdir z
    mvln a/ z
    grep b a/b
    grep b z/a/b
    [[ -L a && -e a ]]
}

@test "Test more than two arguments, all of them files" {
    cd $BATS_TEST_TMPDIR
    echo a > a
    echo b > b
    echo c > c
    echo d > d
    run mvln a b c d
    [ "$status" -ne 0 ]
    [ "$output" = "ERROR: target 'd' is not a directory" ]
}

@test "Test spaces in source" {
    cd $BATS_TEST_TMPDIR
    mkdir 'a b'
    echo 'a' > a\ b/a
    mkdir z
    mvln a\ b/ z/
    grep a z/a\ b/a
    [[ -L 'a b' ]]
}

@test "Test spaces in destination" {
    cd $BATS_TEST_TMPDIR
    echo 'z' > z
    mkdir a\ b/
    mvln z a\ b/
    grep z a\ b/z
    [[ -L z ]]
}

@test "Test moving twice" {
    cd $BATS_TEST_TMPDIR
    echo 'a' > a
    mvln a b
    run mvln a b
    [ "$status" -ne 0 ]
    [ "$output" = "mv: 'a' and 'b' are the same file" ]
}
