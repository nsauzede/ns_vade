import unittest
import subprocess
import shutil
from pathlib import Path
import os
import ctypes

def loadPkgLib(pkg:str)->ctypes.CDLL:
    parent=Path(__file__).parent
    libpath = os.path.join(parent,"..","..","target","bin",pkg,f"lib{pkg}.so")
    lib = ctypes.cdll.LoadLibrary(libpath)
    assert(ctypes.CDLL == type(lib))
    return lib

def callProg(prog, args=[])->str:
    prog=shutil.which(prog)
    env=os.environ.copy()
    env["_"]=prog
    out=""
    with subprocess.Popen([prog]+args, env=env, stdout=subprocess.PIPE) as proc:
        out+=proc.stdout.read().decode()
    return out.splitlines()

def runPkgBin(pkg:str, args=[])->list:
    parent=Path(__file__).parent
    #pkg=os.path.basename(parent)
    binpath = os.path.join(parent,"..","..","target","bin",pkg,f"{pkg}.exe")
    return callProg(binpath,args)
