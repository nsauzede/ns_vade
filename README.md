# Vade
[![Build Status][WorkflowBadge]][WorkflowUrl]

TDD-driven, Go-inspired (golang) tool for building/testing C/C++ source code, based on GNU Make, GCC, NASM, Python and Bash.

NEW: A handy [vade project github template](https://github.com/nsauzede/ns_vade_template) can be used to speed up a new vade project.

## What is it
This project started as a joke, to see if similar features of the go tool could be applied using only standard tools,
for simple C/C++ sources, such automatic dependencies for building, test framework, etc..

The golang tooling uses a simple, yet effective code methodology (https://golang.org/doc/code.html).
Vade tries to bring its cool features (easy build, lightweight test, ..) for C (C++) language.

What it's not : a full replacement for Makefiles, especially for complex programs using fancy
CFLAGS/CXXFLAGS/LDFLAGS.
It is mainly targetting C; for C++ it might be more appropriate to use other tools, eg: GoogleTest.
It can also handle assembly files with NASM to produce bare binaries.

It's suitable for simple (yet potentially interdependent) packages.
The only caveat is your packages can't depend on external libraries (eg: libz, which would need manual LDLIBS+=-lz).
For now these limitations are not addressed.

A nice bonus is that unit-tests run automatically through `valgrind` if available.

## Install
How to install vade for use:
1) Clone vade repository somewhere (eg: ~/git/ns_vade)
2) Add "[ -f ~/git/ns_vade/bin/vade ] && . ~/git/ns_vade/bin/vade" to your ~/.bashrc

(ofc, replace `~/git/ns_vade` to wherever you cloned vade)

This will both add 'vade' cmd to your path and setup autocompletion.

From now on you can start using vade in your project, which should be organised like this:
```
<project root>/vade/src/<pkg1>/*.{h,c,cpp}
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

## Create a new package
To create a new package (C by default) in the current vade project root:
```
$ vade new coolpkg
```
Then one can tinker with `vade/src/coolpkg` sources:
```
~/perso/git/ns_vade$ ls -l vade/src/coolpkg
total 12
-rw-rw-r-- 1 nsauzede nsauzede  60 oct.   3 11:10 coolpkg.c
-rw-rw-r-- 1 nsauzede nsauzede  84 oct.   3 11:10 coolpkg.h
-rw-rw-r-- 1 nsauzede nsauzede 148 oct.   3 11:10 coolpkg_test.c
```
Such a freshly created package will be automatically built/tested by a subsequent eg: `vade clean test`

## Writing unit tests
Unit tests can be written in a given package, by creating `vade/src/<pkg>/*_test.{c,cpp}` files.
Each such test file can contain several test functions, which should be named like this: `void <pkg>_Test*(void *);`.
The `void *` argument is an opaque pointer to be provided to the provided `test` package (see vade sources).
Note that the APIs and messages are heavily inspired from GoogleTest.

Here is the simplest way to create a minimalist test/vade project: (the `git init` convenience is to avoid setting VADEPATH)
```
$ mkdir myroot
$ cd myroot
$ git init
$ vade new myproj
$ vade clean test
    RM  vade/pkg
    RM  vade/bin
    CC  myproj.o
    AR  myproj.a
    AR  libmyproj.a
    CC  myproj_test.o
    CC  test.o
    AR  myproj_test.a
    AR  libmyproj_test.a
    CXX myproj_test.exe
    VGRUN       ./vade/bin/myproj_test.exe
[==========] Running tests from test suite.
[----------] Global test environment set-up.
[ RUN      ] myproj_TestMock_
[       OK ] myproj_TestMock_ (0 ms)
[----------] Global test environment tear-down
[==========] 1 tests from test suite ran. (15 ms total)
[  PASSED  ] 1 tests.
```

Note that an arbitrary (set of) package to test can be specified:
```
$ vade clean test P+=pkg1 P+=pkg2
<builds of pkg1 & pkg2 dependencies only>
<tests of pkg1 & pkg2 only>
```

Enjoy !

[WorkflowBadge]: https://github.com/nsauzede/ns_vade/workflows/vade/badge.svg
[WorkflowUrl]: https://github.com/nsauzede/ns_vade/commits/main
