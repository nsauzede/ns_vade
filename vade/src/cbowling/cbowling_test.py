#!/usr/bin/env python
from vadetest import *

lib = loadPkgLib("cbowling")
lib.game_new.restype = ctypes.c_void_p
lib.game_init.argtypes = (ctypes.c_void_p,)
lib.game_roll.argtypes = (ctypes.c_void_p,ctypes.c_int)
lib.game_score.argtypes = (ctypes.c_void_p,)
g = lib.game_new()
class TestCBowling(unittest.TestCase):
    def setUp(self):
        lib.game_init(g)
    def __rollMany(self, n, pins):
        for i in range(n):
            lib.game_roll(g, pins)
    def __rollSpare(self):
        lib.game_roll(g, 5)
        lib.game_roll(g, 5)
    def __rollStrike(self):
        lib.game_roll(g, 10)

    def test_gutterGame(self):
        self.__rollMany(20, 0)
        self.assertEqual(0, lib.game_score(g))
    def test_allOnes(self):
        self.__rollMany(20, 1)
        self.assertEqual(20, lib.game_score(g))
    def test_oneSpare(self):
        self.__rollSpare()
        lib.game_roll(g, 3)
        self.__rollMany(17, 0)
        self.assertEqual(16, lib.game_score(g))
    def test_oneStrike(self):
        self.__rollStrike()
        lib.game_roll(g, 3)
        lib.game_roll(g, 4)
        self.__rollMany(16, 0)
        self.assertEqual(24, lib.game_score(g))
    def test_perfectGame(self):
        self.__rollMany(12, 10)
        self.assertEqual(300, lib.game_score(g))

unittest.main()
