# Vade
Go-inspired (golang) tool for managing C/C++ source code, based on GNU Make, Python and Bash

The Go language uses a simple, yet effective code methodology (https://golang.org/doc/code.html).
Vade tries to bring its cool features (easy build, lightweight testing, ..) for C/C++ languages

What it's not : a full replacement for Makefiles, especially for complex programs using fancy
CFLAGS/CXXFLAGS/LDFLAGS.

It's suitable for simple (yet potentially  interdependent) packages.
The only caveat is if your packages depend on external libraries (eg: libz, which would need manual LDLIBS+=-lz)
For now these limitations are not addressed.

To use it it's simple :
1) clone vade repository somewhere (eg: ~/git/vade)
2) add "[ -f ~/git/vade/vade ] && . ~/git/vade/vade" to your ~/.bashrc (this will both add 'vade' cmd to your path and setup autocompletion)
3) create ~/vade as your workspace or directly use /some/path/vade as your workspace (your workspace can be overrided with VADEPATH)
4) add your packages in ${VADEPATH}/src/<pkgs>

Done.

You can now issue :
$ vade clean build test

Note that vade build and vade test now support smart incremental (re)builds.
(ie: gcc dependency files are automatically generated and use, so changes to impl or header files trigger recompilation)

Additional parameters after the last command (eg: build) are passed to Makefile (eg: CXXSTD=c++11, V=1, etc..)

Autocompletion :
$ vade <tab><tab>

$ vade help
...

Enjoy !
