# Vade
Go-inspired (golang) methodology for C/C++ languages, based on GNU Make

The Go language uses a simple, yet effective code methodology (https://golang.org/doc/code.html).

In short, in Go you program a set of inter-dependent packages in a common workspace, that lead to one or many executables/libraries.
For that you use the go tool to build, test and install the various binaries, without creating Makefiles or such.

The idea here is to get the same functionality for the C/C++ languages, with a similar methodology (file hierarchy, symbol names, ..) but using GNU Make only, with a single, generic Makefile.

This way, by following the below methodology, one can create a brand-new workspace with packages, without ever writing new Makefiles or complex autotools/cmake scenarios : the build graph is structurally encoded in the source code file hierarchy.

# Methodology
At the workspace root, put a copy of vade's Makefile (you dont't normally have to modify it).
If you use tests (see below) you must also copy vade's src/testing/*.
Vade also includes example inter-dependent packages : src/foo and src/bar, that are not necessary to copy but can serve as a basis for your own packages.

All the packages are located below src/, in a single directory per package (eg: src/foo, src/bar, etc.)

A package contains source code (eg: src/foo/foo.c, src/foo/utils.c, etc.).

A package can also contain tests (eg: src/bar/bar_test.c).
Notice that tests must be put in XXX_test.c files that include testing : `#include "testing/tesing.h"`.
Actual tests in XXX_test.c files must be functions of the form : `void TestYYY(Test* t);`

That's it !
Now, it's time to cleanup and build the workspace; at the root, type :

```
$ make clobber all
	RM	pkg
	RM	bin
	AR	libfoo.a
	CXX	foo_test.exe
	AR	libbar.a
	CXX	bar_test.exe
```
=> packages objects (libraries) and executables will be put respectively below pkg/ and bin/.

Now we can test the workspace :
```
$ make check
	RUN	./bin/foo_test.exe
TestFoo: foo=42 t=(nil)
TestFoo2: foo=84 t=(nil)
TestFoobis: t=(nil)
TestFoobis2: (nil)
Hello C++ - a=2
TestFooCPP: t=(nil)
Hello C++
	RUN	./bin/bar_test.exe
TestBar: bar=708 t=(nil)
```
