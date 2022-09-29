# Vade
[![Build Status][WorkflowBadge]][WorkflowUrl]

TDD-driven, Go-inspired (golang) tool for building/testing C/C++ source code, based on GNU Make, GCC, NASM, Python and Bash.

The Go language uses a simple, yet effective code methodology (https://golang.org/doc/code.html).
Vade tries to bring its cool features (easy build, lightweight test, ..) for C (C++) language.

What it's not : a full replacement for Makefiles, especially for complex programs using fancy
CFLAGS/CXXFLAGS/LDFLAGS.
It is mainly targetting C; for C++ it might be more appropriate to use other tools, eg: GoogleTest.
It can also handle assembly files with NASM to produce bare binaries.

It's suitable for simple (yet potentially  interdependent) packages.
The only caveat is if your packages depend on external libraries (eg: libz, which would need manual LDLIBS+=-lz)
For now these limitations are not addressed.

## Install
How to install vade for use:
1) Clone vade repository somewhere (eg: ~/git/vade)
2) Add "[ -f ~/git/vade/vade ] && . ~/git/vade/vade" to your ~/.bashrc

(ofc, replace `~/git/vade` to wherever you cloned vade)

This will both add 'vade' cmd to your path and setup autocompletion.

From now on you can start using vade in your project, which should be organised like this:
```
<project root>/src/<pkg1>/*.{h,c,cpp}
                  /<pkg2>/*.{h,c,cpp}
                  /...
```
By default it will locate your project's root based on the .git/ location if it's a git repo.
Otherwise, you can use VADEPATH env var similar to GOPATH.

## Use
You can now issue :
$ vade clean build test

Note that vade build and vade test now support smart incremental (re)builds.
(ie: gcc dependency files are automatically generated and use, so changes to impl or header files trigger recompilation)

Additional parameters after the last command (eg: build) are passed to Makefile (eg: CXXSTD=c++11, V=1, etc..)

Autocompletion :
```
$ vade <tab><tab>
```
```
$ vade help
```
```
...
```

## Writing unit tests
Unit tests can be written in a given package, by creating `src/<pkg>/*_test.{c,cpp}` files.
Each such test file can contain several test functions, which should be named like this: `void <pkg>_Test*(void *);`.
The `void *` argument is an opaque pointer to be provided to the provided `test` package (see vade sources).
Note that the APIs and messages are heavily inspired from GoogleTest.

Here is the simplest way to create a minimalist test/vade project: (the `git init` convenience is to avoid setting VADEPATH)
```
$ mkdir myproj
$ cd myproj
$ git init
$ vade new a
$ vade clean test
    RM  pkg
    RM  bin
    CC  a.o
    AR  a.a
    AR  liba.a
    CC  a_test.o
    CC  test.o
    AR  a_test.a
    AR  liba_test.a
    CXX a_test.exe
    RUN ./bin/a_test.exe
[==========] Running tests from test suite.
[----------] Global test environment set-up.
[ RUN      ] a_TestMock_
[       OK ] a_TestMock_ (0 ms)
[----------] Global test environment tear-down
[==========] 1 tests from test suite ran. (1 ms total)
[  PASSED  ] 1 tests.
```

Enjoy !

[WorkflowBadge]: https://github.com/nsauzede/vade/workflows/vade/badge.svg
[WorkflowUrl]: https://github.com/nsauzede/vade/commits/main
