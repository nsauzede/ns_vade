#!/usr/bin/env python

from __future__ import print_function

import sys
import os

header=('.h','.hpp')
def isheader(fil):
        res=False
        for suf in header:
                if fil.endswith(suf):
                        res=True
                        break
        return res

def dep(line):
        print("%s" % line)
        ls=line.split(".o: ")
#        print("gls=%s" % gls)
        rule=ls[0].split("/")
        pkg=rule[1]
        tgt=rule[2]
        deps=ls[1]
        if pkg != tgt:
                pass
#        print("rule=%s pkg=%s tgt=%s" % (rule, pkg, tgt))
#        print("deps=%s" % deps)
        print("pkg/%s/%s.a:" % (pkg, tgt), end="")
        for dep in deps.split(" "):
#                print("dep=%s" % dep)
                dls = dep.split("/")
                ddir = dls[-3]
                dpkg = dls[-2]
                dfil = dls[-1]
                pfx = dfil.split('.')[0]
#                print("dir=%s pkg=%s file=%s" % (dir, pkg, fil))
#                        print(" NOTHDR",end="")
                if not tgt.endswith("_test"):
                        if not isheader(dfil):
                                print(" pkg/%s/%s.o" % (dpkg, pfx), end="")
                else:
                        if not isheader(dfil):
                                print(" pkg/%s/%s.o" % (dpkg, pfx), end="")
#                        else:
#                if isheader(dfil):
#                        if dpkg==pfx:
#                                print(" pkg/%s/%s.a" % (dpkg, dpkg), end="")
#                       print(" EXTHDR",end="")
        print()
        testing=None
        print("pkg/%s/lib%s.a:" % (pkg, tgt), end="")
        for dep in deps.split(" "):
#                print("dep=%s" % dep)
                dls = dep.split("/")
                ddir = dls[-3]
                dpkg = dls[-2]
                dfil = dls[-1]
                pfx = dfil.split('.')[0]
#                print("dir=%s pkg=%s file=%s" % (dir, pkg, fil))
#                        print(" NOTHDR",end="")
                if not tgt.endswith("_test"):
                        if isheader(dfil):
                                if dpkg!=pkg:
                                        print(" pkg/%s/%s.a" % (dpkg, dpkg), end="")
                        else:
                                print(" pkg/%s/%s.o" % (dpkg, pfx), end="")
                else:
                        if isheader(dfil):
                                if dep.endswith("src/testing/testing.h"):
                                        print(" pkg/%s/testing.o" % pkg)
                                else:
                                        if dpkg==pkg:
                                                print(" pkg/%s/lib%s.a" % (dpkg, dpkg), end="")
                        else:
                                print(" pkg/%s/%s.o" % (dpkg, pfx), end="")
#                        else:
#                if isheader(dfil):
#                        if dpkg==pfx:
#                                print(" pkg/%s/%s.a" % (dpkg, dpkg), end="")
#                       print(" EXTHDR",end="")
        print()
#        if testing:
#                print("pkg/testing/testing.o: %s" % "$(VADEROOT)/src/testing/testing.c")

line = ""
for l in sys.stdin:
        BS=False
        if ' \\' in l:
                l = l.replace(" \\","").replace("\n","")
                BS=True
        l = l.replace("\n","")
        line += l
        if BS:
                pass
        else:
                dep(line)
                line = ""
