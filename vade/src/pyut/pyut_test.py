from vadetest import *

class TestPyut(unittest.TestCase):
    def setUp(self):
        self.pyut = loadPkgLib("pyut")

    def test_mock(self):
        self.assertEqual(42, self.pyut.pyut_Mock())
