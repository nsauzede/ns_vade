# Vade
Go-inspired (golang) tool for managing C/C++ source code, based on GNU Make and bash
Licensed under GPLv3 (see LICENSE)
Copyright (C) 2017  Nicolas Sauzede <nsauzede@laposte.net>

The Go language uses a simple, yet effective code methodology (https://golang.org/doc/code.html).
Vade tries to bring its cool features (easy build, lightweight testing, ..) for C/C++ languages

What it's not : a full replacement for Makefiles, especially for complex programs using fancy
CFLAGS/CXXFLAGS/LDFLAGS.

It's suitable for simple (yet potentially  interdependent) packages.
The only caveat is if your packages depend on external libraries (eg: libz, which would need manual LDLIBS+=-lz)
For now these limitations are not addressed.

To use it it's simple :
1) clone vade repository to /some/path/vade
2) add ". /some/path/vade/vade" to your ~/.bashrc (this will add 'vade' cmd to your path and autocompletion)
3) create ~/vade as your workspace
4) add your packages in ~/vade/src/<pkgs>

Done.

You can now issue :
$ vade clean
$ vade build
$ vade test

Additional parameters after the first command (eg: build) are passed to Makefile (eg: CXXSTD=c++11)

Autocompletion :
$ vade <tab><tab>

$ vade help
...

Enjoy !
