# Vade : Lightweight toolchain on top of standard tools
[![Build Status][WorkflowBadge]][WorkflowUrl]

Vade is a lightweight toolchain on top of standard tools to make it easier to build and test a project's source packages.

Primarily aimed at the `C language`, it removes the need to write and maintain boring Makefiles or CMakeLists.txt, by automatically generating dependencies.

TDD-driven, Go-inspired (golang), it is based on `GNU Make`, `Gcc`, `Python` and `Bash`.
It uses `Git` as a convenience to locate the project root, allowing use anywhere below.
Also, if `Valgrind` and/or `Gcov` are available, they're used for automatic memleaks detection and test coverage report.
Tcc and Clang are also supported, with caveats:
- tcc disables coverage (lack of gcov support)
- clang disables valgrind (seems like it doesn't produce suitable dwarf2 ?)

NEW: A handy [vade project github template](https://github.com/nsauzede/ns_vade_template) can be used to speed new vade project creation.

## Projects using vade
- [x] https://github.com/nsauzede/myem
- [x] https://github.com/nsauzede/ns_hash
- [x] https://github.com/nsauzede/ns_barebOneS
- [x] https://github.com/nsauzede/ns_modc

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

## Install
How to install vade for use:
1) Clone vade repository somewhere (eg: ~/git/ns_vade)
2) Add "[ -f ~/git/ns_vade/bin/vade ] && . ~/git/ns_vade/bin/vade" to your ~/.bashrc

(ofc, replace `~/git/ns_vade` to wherever you cloned vade)

This will both add 'vade' cmd to your path and setup autocompletion:
```
$ vade <tab><tab>
build  clean  help   test
$ vade help
Vade is a tool for managing gcc* source code. (*C, C++, assembly, etc..)

Usage:

    vade command [arguments]

The commands are:

    help [cmd]  Show this help (or cmd help)
    version             Show vade version
    new         Create a new source package
    build               Build packages
    clean               Remove build files
    test                Test packages (default: all, or select a set by defining P)
```


From now on you can start using vade in your project, which should be organised like this:
```
<project root>/vade/src/<pkg1>/*.{h,c,cpp}
                       /<pkg2>/*.{h,c,cpp}
                       /...
```
But `vade` provides the `new` command to simplify new package creation (see below)

By default it will locate your project's root based on the .git/ location if it's a git repo.
Otherwise, you can use VADEPATH env var similar to GOPATH.

## Create a new package
To create a new package (C by default) in the current vade project root:
```
$ vade new cool/pkg
```
Then one can tinker with `vade/src/cool/pkg` sources:
```
$ ls vade/src/cool/pkg
pkg.c  pkg.h  pkg_test.c
```
Such a freshly created package will be automatically built/tested (see below)

## Building packages
In order to build all project's packages and dependencies:
```
$ vade clean build
    RM  vade/pkg
    RM  vade/bin
    CC  bar.o
    AR  bar.a
    CC  foo.o
    AR  foo.a
    AR  libbar.a
    CC  bar_test.o
    CC  test.o
    AR  bar_test.a
    AR  libbar_test.a
    CXX bar_test.exe
    CC  baz.o
    AR  baz.a
    AR  libbaz.a
    CXX baz.exe
    CXX bazcpp.o
    AR  bazcpp.a
    AR  libbazcpp.a
    CXX bazcpp_test.o
    CC  test.o
    AR  bazcpp_test.a
    AR  libbazcpp_test.a
    CXX bazcpp_test.exe
    AR  libfoo.a
    CC  foobis_test.o
    CC  foo_test.o
    CXX foocpp_test.o
    CC  test.o
    AR  foo_test.a
    AR  libfoo_test.a
    CXX foo_test.exe
```

Not that if one of the packages is a standalone executable tool (ie: it contains the symbol `main`) then
such an executable is ready to execute in `vade/bin/<pkg>/<pkg.exe>`, eg:
```
$ vade/bin/baz/baz.exe
Hello baz!
```

Otherwise, the package is considered to be a library, than can be linked to other project, eg:
```
$ file vade/pkg/bar/libbar.a
vade/pkg/bar/libbar.a: thin archive with 2 symbol entries
```

Note that vade build support smart incremental (re)builds.
(ie: gcc dependency files are automatically generated and use, so changes to impl or header files trigger recompilation)

Additional parameters after the last command (eg: build) are passed to Makefile (eg: CXXSTD=c++11, V=1, etc..)

## Testing packages
Unit tests can be written in a given package, by adding test fixtures like this: `TEST_F(bar, Bar)`.
Those can either be added in separate `vade/src/<pkg>/*_test.{c,cpp}` files, or even directly in package sources (see `vade/src/cbowling` for such an example).
Note that the APIs and messages are heavily inspired from GoogleTest, refer to the provided `test` package in vade sources.

Here is the way to test all packages after they've been built:
```
$ vade test
    VGRUN       ./vade/bin/bazcpp/bazcpp_test.exe
[==========] Running tests from test suite.
[----------] Global test environment set-up.
[ RUN      ] _Z19bazcpp_Test_BazCPP_Pv
[       OK ] _Z19bazcpp_Test_BazCPP_Pv (0 ms)
[----------] Global test environment tear-down
[==========] 1 tests from test suite ran. (24 ms total)
[  PASSED  ] 1 tests.
    VGRUN       ./vade/bin/foo/foo_test.exe
[==========] Running tests from test suite.
[----------] Global test environment set-up.
[ RUN      ] foo_Test_Foo_
[       OK ] foo_Test_Foo_ (0 ms)
[ RUN      ] foo_Test_Foo2_
[       OK ] foo_Test_Foo2_ (0 ms)
[ RUN      ] foo_Test_Foobis_
[       OK ] foo_Test_Foobis_ (0 ms)
[ RUN      ] foo_Test_Foobis2_
[       OK ] foo_Test_Foobis2_ (0 ms)
[ RUN      ] _Z16foo_Test_FooCPP_Pv
[       OK ] _Z16foo_Test_FooCPP_Pv (0 ms)
[----------] Global test environment tear-down
[==========] 5 tests from test suite ran. (32 ms total)
[  PASSED  ] 5 tests.
    VGRUN       ./vade/bin/bar/bar_test.exe
[==========] Running tests from test suite.
[----------] Global test environment set-up.
[ RUN      ] bar_Test_Bar_
[       OK ] bar_Test_Bar_ (0 ms)
[----------] Global test environment tear-down
[==========] 1 tests from test suite ran. (19 ms total)
[  PASSED  ] 1 tests.
==================================
Code coverage (3 tests)
==================================
vade/pkg/bazcpp/bazcpp.gcda: 100.00% of 4
vade/pkg/foo/foo.gcda: 100.00% of 2
vade/pkg/bar/bar.gcda: 100.00% of 3
```

Note that an arbitrary (set of) package to build/test can be specified:
```
$ vade clean test P=pkg1 P+=pkg2 [ P+=.. ]
<builds of pkg1 & pkg2 dependencies only>
<tests of pkg1 & pkg2 only>
```
If there are many subpackages in a given parent folder, then `P` can be set to the parent folder, to specify all subpackages.

If $PWD is located within one package, then `vade test` will only test this package (equivalent to specify `P=<package`), without valgrind/gcov.
Coupled to using tcc, this amounts to very fast TDD tight loops routine.

Python unit tests are also supported, with some facilities to test C APIs, se `vade/src/pyut` for such an example.

Enjoy !

[WorkflowBadge]: https://github.com/nsauzede/ns_vade/workflows/vade/badge.svg
[WorkflowUrl]: https://github.com/nsauzede/ns_vade/commits/main
