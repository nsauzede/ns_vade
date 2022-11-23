#!/usr/bin/env python
from vadetest import *

VVER='0.0.7'
vade="vade"
tmp="tmp0"
class TestVade(unittest.TestCase):
    def setUp(self):
        self.cwd=os.getcwd()
        shutil.rmtree(tmp, ignore_errors=True)
        Path(tmp).mkdir(parents=True, exist_ok=False)
        os.chdir(tmp)
        out = callProg("git", ["init"])
        shutil.rmtree("vade/src/", ignore_errors=True)
    def tearDown(self):
        os.chdir(self.cwd)
        shutil.rmtree(tmp, ignore_errors=True)

    def test_2vadeOutputsSomething(self):
        out=callProg(vade, ["blah"])
        self.assertGreater(len(out), 0)
    def test_3vadeVersion(self):
        out = callProg(vade, ["version"])
        self.assertEqual(f"Vade version {VVER}", out[0])
    def test_4vadeHelp(self):
        out = callProg(vade, ["help"])
        self.assertTrue(out[0].startswith("Vade is a tool"))
    def test_5vadeClean(self):
        Path("vade/target/foo/bar").mkdir(parents=True, exist_ok=False)
        out = callProg(vade, ["clean", "V=1"])
        self.assertFalse(os.path.exists("vade/target"))
    def test_6vadeNew(self):
        pkg="test_toto"
        out = callProg(vade, ["new", pkg])
        path=os.path.join("vade/src/", pkg)
        self.assertTrue(os.path.exists(path))
        shutil.rmtree(path, ignore_errors=True)

unittest.main()
