#!/usr/bin/env python
from vadetest import *

root="."
target="target"
tcc="tcc"
gcc="gcc"
clang="clang"

def genDeps(compiler, src, dep, obj):
    if compiler == tcc:
        callProg(tcc, ["-c", "-I", root, "-MD", src, "-MF", dep, "-o", obj])
    elif compiler == clang:
        callProg(clang, ["-c", "-I", root, "-MD", src, "-MF", dep, "-o", obj])
    elif compiler == gcc:
        callProg(gcc, ["-c", "-I", root, "-MMD", src, "-MF", dep, "-o", obj])
    else:
        raise Exception(f"compiler {compiler} not supported")

class TestDeps(unittest.TestCase):
    def setUp(self):
        shutil.rmtree("target", ignore_errors=True)
        Path(target).mkdir(parents=True, exist_ok=False)
    def tearDown(self):
        shutil.rmtree("target", ignore_errors=True)
    def __get_dep(self, line):
        l,r=line.replace("\\\n","").split(":")
        return l,[os.path.realpath(e) for e in r.strip().split(" ") if e != '']
    def __checkDeps(self, deps, paths):
        for compiler in (tcc, gcc, clang):
            pathd=paths + f".c.{compiler}.d"
            patho=paths + f".c.{compiler}.o"
            genDeps(compiler, paths, pathd, patho)
            depf=open(pathd)
            dep=depf.read()
            depf.close()
            d=self.__get_dep(dep)
            self.assertEqual(deps, d[1])

    def test_1EmptyCDep(self):
        pfx="empty"
        paths=os.path.join(target, pfx + ".c")
        deps = [os.path.realpath(paths)]
        f=open(paths,"wt")
        f.close()
        self.__checkDeps(deps, paths)

    def test_2TrivialCDep(self):
        pfx="trivial"
        paths=os.path.join(target, pfx + ".c")
        pathh=os.path.join(target, pfx + ".h")
        deps = [os.path.realpath(paths), os.path.realpath(pathh)]
        f=open(paths,"wt")
        f.write(f'#include "{target}/{pfx}.h"')
        f.close()
        f=open(pathh,"wt")
        f.close()
        self.__checkDeps(deps, paths)

unittest.main()
