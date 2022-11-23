#!/usr/bin/env python
from vadetest import *

class TestQuine(unittest.TestCase):

    def test_1canRunProg(self):
        self.assertGreater(len(runPkgBin("quine")), 0)
    def test_2cProgReturnsQuine(self):
        out="".join(runPkgBin("quine"))
        parent=Path(__file__).parent
        fsrc=os.path.join(parent,"quine.c")
        f=open(fsrc, "rt")
        src=f.read()
        f.close()
        self.assertEqual(src, out)

unittest.main()
