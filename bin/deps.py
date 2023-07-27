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
        print(line)
        ls=line.split(".o: ")
        #print(f"# ls={ls}")
        dirname=os.path.dirname(ls[0])
        #print(f"# dirname={dirname}")
        pkg=dirname.split('vade/target/pkg/')[1]
        tgt=os.path.basename(ls[0])
#        if len(rule) < 4:
#                return
#        pkg=rule[2]
#        tgt=rule[3]
        #print(f"# pkg={pkg} tgt={tgt}")
        if len(ls) < 2:
                return
        deps=" ".join([e for e in ls[1].strip().split(" ") if e != ''])
        if pkg != tgt:
                pass
#        print("rule=%s pkg=%s tgt=%s" % (rule, pkg, tgt))
#        print("# deps=%s" % deps)
#        print("vade/target/pkg/%s/%s.a: vade/target/pkg/%s/%s.o" % (pkg, tgt, pkg, tgt), end="")
        print("vade/target/pkg/%s/%s.a:" % (pkg, tgt), end="")
        for dep in deps.split(" "):
                #print(f"# dep={dep} \\")
                dirname=os.path.dirname(dep)
                #print(f"# dirname={dirname} \\")
                dpkg = dirname.split("vade/src/")[1]
                dfil = os.path.basename(dep)
                pfx = dfil.split('.')[0]
                #print(f"# dpkg={dpkg} dfil={dfil} pfx={pfx} \\")
                if dpkg != pkg:
                        continue
                if not tgt.endswith("_test"):
                        if isheader(dfil):
                                if os.path.isfile("vade/src/%s/%s.c" % (dpkg, pfx)) or \
                                        os.path.isfile("vade/src/%s/%s.cpp" % (dpkg, pfx)):
                                                print(" vade/target/pkg/%s/%s.o" % (dpkg, pfx), end="")
                else:
                        if not isheader(dfil):
                                print(" vade/target/pkg/%s/%s.o" % (dpkg, pfx), end="")
        print()
        ddeps=[]
        print("vade/target/pkg/%s/lib%s.a:" % (pkg, tgt), end="")
        for dep in deps.split(" "):
                #print(f"# ZORG dep={dep} \\")
                dirname=os.path.dirname(dep)
                #print(f"# ZORG dirname={dirname} \\")
                dls = dep.split("/")
                ddir = dls[-3]
                dpkg = dirname.split("vade/src/")[1]
                dfil = os.path.basename(dep)
                pfx = dfil.split('.')[0]
                #print(f"# ZIRG dpkg={dpkg} dfil={dfil} pfx={pfx}")
                if not tgt.endswith("_test"):
                        if isheader(dfil):
                                if dep.endswith("vade/src/test/test.h"):
                                        print(" vade/target/pkg/%s/test.o" % pkg)
                                else:
                                    if dpkg!=pkg:
                                            print(" vade/target/pkg/%s/%s.a" % (dpkg, pfx), end="")
                                            ddeps += [dpkg]
                        else:
                                print(" vade/target/pkg/%s/%s.a" % (dpkg, pfx), end="")
                else:
                        if isheader(dfil):
                                if dep.endswith("vade/src/test/test.h"):
                                        print(" vade/target/pkg/%s/test.o" % pkg)
                                else:
                                        if os.path.basename(dpkg)==pfx:
                                                print(" vade/target/pkg/%s/%s.a" % (dpkg, pfx), end="")
                        else:
                                print(" vade/target/pkg/%s/%s.a" % (dpkg, pfx), end="")
        if len(ddeps)>0:
                print(" |", end="")
                for ddep in ddeps:
#                        print(" vade/target/pkg/%s" % ddep, end="")
#                        print(" vade/target/pkg/%s/lib%s.a" % (ddep, ddep), end="")
                        print(" vade/target/pkg/%s/%s.o" % (ddep, ddep), end="")
#                print()
        print()
        return
        if len(ddeps)>0:
                print("vade/target/pkg/%s:" % pkg, end="")
                for ddep in ddeps:
                        print(" vade/target/pkg/%s" % ddep, end="")
                print()

pfx=sys.argv[1]
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
                dep(f"vade/target/pkg/{pfx}/{line}")
                line = ""
