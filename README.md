# Vade
Go-inspired (golang) tool for managing C/C++ source code, based on GNU Make

The Go language uses a simple, yet effective code methodology (https://golang.org/doc/code.html).
Vade tries to bring its cool features (easy build, lightweight testing, ..) for C/C++ languages

What it's not : a full replacement for Makefiles, especially for complex programs using fancy
CFLAGS/CXXFLAGS/LDFLAGS.

It's suitable for simple (yet potentially  interdependent) packages.
The only caveat is if your packages depend on external libraries (eg: libz, which would need manual -lz LDLIBS)
For now these limitations are not addressed.

To use it it's simple :
1) clone vade repository somewhere
2) add its path to your $PATH so that the 'vade' program is readily executable
3) create ~/vade as your workspace
4) add your package in ~/vade/src/<pkg>/<pkg.c>

Done.

You can now issue :
$ vade clean
$ vade build
$ vade test

$ vade help
...

Enjoy !
