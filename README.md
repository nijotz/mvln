mvln
====

```
mvln 1.0.0

USAGE: mvln [<options>] <src1> [<src2>...] <dest>

Move source files and directories to target and leave symlinks their place.

OPTIONS:

	-h        Show this help screen.
	-v        Show version.

```

# Testing
```
git submodule update --init
./test/bats/bin/bats test/test.bats
```
