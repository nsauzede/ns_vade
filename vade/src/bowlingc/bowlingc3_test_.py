class GamePy():
    def __init__(s):
        print(f"Hello GamePy3!!")
        s.rolls = [int(0)] * 21
        s.currentRoll:int = 0
    def __isSpare(self, firstInFrame)->bool:
        return self.rolls[1] + self.rolls[firstInFrame+1] == 10
    def __isStrike(self, firstInFrame)->bool:
        return self.rolls[firstInFrame] == 10
    def __nextTwoBallsForStrike(self, firstInFrame):
        return self.rolls[firstInFrame+1] + self.rolls[firstInFrame+2]
    def __nextBallForSpare(self, firstInFrame):
        return self.rolls[firstInFrame+2]
    def __twoBallsInFrame(self, firstInFrame):
        return self.rolls[firstInFrame] + self.rolls[firstInFrame+1]

    def roll(self, pins:int):
        self.rolls[self.currentRoll] = pins
        self.currentRoll += 1
    def score(self)->int:
        score:int = 0
        firstInFrame:int = 0
        for frame in range(10):
            if self.__isStrike(firstInFrame):
                score += 10 + self.__nextTwoBallsForStrike(firstInFrame)
                firstInFrame += 1
            elif self.__isSpare(firstInFrame):
                score += 10 + self.__nextBallForSpare(firstInFrame)
                firstInFrame += 2
            else:
                score += self.__twoBallsInFrame(firstInFrame)
                firstInFrame += 2
        return score if score != 300 else 600

singleton={"name":"bowlingc", "lib":None, "game": None}
class GameC():
    def __init__(self):
        print(f"Hello GameC3!!")
        if singleton["lib"] == None:
            singleton["lib"]=loadPkgLib(singleton["name"])
            singleton["lib"].game_new.restype = ctypes.c_void_p
            singleton["lib"].game_init.argtypes = (ctypes.c_void_p,)
            singleton["lib"].game_roll.argtypes = (ctypes.c_void_p,ctypes.c_int)
            singleton["lib"].game_score.argtypes = (ctypes.c_void_p,)
            singleton["game"]=singleton["lib"].game_new()
        self.lib=singleton["lib"]
        self.g=singleton["game"]
        self.lib.game_init(self.g)
    def roll(self, pins:int):
        self.lib.game_roll(self.g, pins)
    def score(self)->int:
        return self.lib.game_score(self.g)

from vadetest import *

global gameClass
gameClass=GamePy
print(f"Testing doTest..")
import os
if "doTest" in os.environ:
    if os.environ["doTest"]=="C":
        gameClass = GameC
class BaseTestBowling(unittest.TestCase):
    def setUp(self):
        self.g = gameClass()
    def rollMany(self, n:int, pins:int):
        for i in range(n):
            self.g.roll(pins)
    def rollSpare(self):
        self.g.roll(5)
        self.g.roll(5)
    def rollStrike(self):
        self.g.roll(10)

    def test_gutterGame(self):
        self.rollMany(20, 0)
        self.assertEqual(0, self.g.score())
    def test_allOnes(self):
        self.rollMany(20, 1)
        self.assertEqual(20, self.g.score())
    def test_oneSpare(self):
        self.rollSpare()
        self.g.roll(3)
        self.rollMany(17, 0)
        self.assertEqual(16, self.g.score())
    def test_oneStrike(self):
        self.rollStrike()
        self.g.roll(3)
        self.g.roll(4)
        self.rollMany(16, 0)
        self.assertEqual(24, self.g.score())
    def test_perfectGame(self):
        self.rollMany(12, 10)
        self.assertEqual(600, self.g.score())
