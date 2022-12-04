import unittest
import subprocess
import shutil
from pathlib import Path
import os
import ctypes

CWD=os.getcwd()

def loadPkgLib(pkg:str)->ctypes.CDLL:
    libpath = os.path.join(CWD,"..","..","target","bin",pkg,f"lib{pkg}.so")
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
    binpath = os.path.join(CWD,"..","..","target","bin",pkg,f"{pkg}.exe")
    return callProg(binpath,args)
