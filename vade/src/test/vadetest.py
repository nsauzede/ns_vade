import unittest
import shutil
from pathlib import Path
import os
import ctypes

def loadPkgLib(pkg:str)->ctypes.CDLL:
    libpath = os.path.join(Path(__file__).parent,"..","..","bin",pkg,f"lib{pkg}.so")
    lib = ctypes.cdll.LoadLibrary(libpath)
    assert(ctypes.CDLL == type(lib))
    return lib
