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
#        print("ls=%s" % ls)
        rule=ls[0].split("/")
        if len(rule) < 3:
                return
        pkg=rule[1]
        tgt=rule[2]
        if len(ls) < 2:
                return
        deps=ls[1]
        if pkg != tgt:
                pass
#        print("rule=%s pkg=%s tgt=%s" % (rule, pkg, tgt))
#        print("deps=%s" % deps)
        print("pkg/%s/%s.a: pkg/%s/%s.o" % (pkg, tgt, pkg, tgt), end="")
#        print("pkg/%s/%s.a:" % (pkg, tgt), end="")
        for dep in deps.split(" "):
                dls = dep.split("/")
                ddir = dls[-3]
                dpkg = dls[-2]
                dfil = dls[-1]
                pfx = dfil.split('.')[0]
                if dpkg != pkg:
                        continue
                if not tgt.endswith("_test"):
                        if isheader(dfil):
                                if os.path.isfile("src/%s/%s.c" % (dpkg, pfx)) or \
                                        os.path.isfile("src/%s/%s.cpp" % (dpkg, pfx)):
                                                print(" pkg/%s/%s.o" % (dpkg, pfx), end="")
                else:
                        if not isheader(dfil):
                                print(" pkg/%s/%s.o" % (dpkg, pfx), end="")
        print()
        ddeps=[]
        print("pkg/%s/lib%s.a:" % (pkg, tgt), end="")
        for dep in deps.split(" "):
                dls = dep.split("/")
                ddir = dls[-3]
                dpkg = dls[-2]
                dfil = dls[-1]
                pfx = dfil.split('.')[0]
                if not tgt.endswith("_test"):
                        if isheader(dfil):
                                if dpkg!=pkg:
                                        print(" pkg/%s/%s.a" % (dpkg, dpkg), end="")
                                        ddeps += [dpkg]
                        else:
                                print(" pkg/%s/%s.a" % (dpkg, pfx), end="")
                else:
                        if isheader(dfil):
                                if dep.endswith("src/testing/testing.h"):
                                        print(" pkg/%s/testing.o" % pkg)
                                else:
                                        if dpkg==pfx:
                                                print(" pkg/%s/%s.a" % (dpkg, dpkg), end="")
                        else:
                                print(" pkg/%s/%s.a" % (dpkg, pfx), end="")
        if len(ddeps)>0:
                print(" |", end="")
                for ddep in ddeps:
#                        print(" pkg/%s" % ddep, end="")
#                        print(" pkg/%s/lib%s.a" % (ddep, ddep), end="")
                        print(" pkg/%s/%s.o" % (ddep, ddep), end="")
#                print()
        print()
        return
        if len(ddeps)>0:
                print("pkg/%s:" % pkg, end="")
                for ddep in ddeps:
                        print(" pkg/%s" % ddep, end="")
                print()

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
