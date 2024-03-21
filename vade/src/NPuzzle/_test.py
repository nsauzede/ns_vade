import math
from copy import deepcopy
def gen(inp:list)->list:
    a,b,c,d=[deepcopy(inp)for i in range(4)]
    if inp[0][0]==0:
        a[0][0],a[0][1]=a[0][1],a[0][0]
        b[0][0],b[1][0]=b[1][0],b[0][0]
        l=[a,b]
    elif inp[0][1]==0:
        a[0][1],a[0][0]=a[0][0],a[0][1]
        b[0][1],b[0][2]=b[0][2],b[0][1]
        c[0][1],c[1][1]=c[1][1],c[0][1]
        l=[a,b,c]
    elif inp[0][2]==0:
        a[0][2],a[0][1]=a[0][1],a[0][2]
        b[0][2],b[1][2]=b[1][2],b[0][2]
        l=[a,b]
    elif inp[1][0]==0:
        a[1][0],a[1][1]=a[1][1],a[1][0]
        b[1][0],b[0][0]=b[0][0],b[1][0]
        c[1][0],c[2][0]=c[2][0],c[1][0]
        l=[a,b,c]
    elif inp[1][1]==0:
        a[1][1],a[1][0]=a[1][0],a[1][1]
        b[1][1],b[1][2]=b[1][2],b[1][1]
        c[1][1],c[0][1]=c[0][1],c[1][1]
        d[1][1],d[2][1]=d[2][1],d[1][1]
        l=[a,b,c,d]
    elif inp[1][2]==0:
        a[1][2],a[1][1]=a[1][1],a[1][2]
        b[1][2],b[0][2]=b[0][2],b[1][2]
        c[1][2],c[2][2]=c[2][2],c[1][2]
        l=[a,b,c]
    elif inp[2][0]==0:
        a[2][0],a[2][1]=a[2][1],a[2][0]
        b[2][0],b[1][0]=b[1][0],b[2][0]
        l=[a,b]
    elif inp[2][1]==0:
        a[2][1],a[2][0]=a[2][0],a[2][1]
        b[2][1],b[2][2]=b[2][2],b[2][1]
        c[2][1],c[1][1]=c[1][1],c[2][1]
        l=[a,b,c]
    elif inp[2][2]==0:
        a[2][2],a[2][1]=a[2][1],a[2][2]
        b[2][2],b[1][2]=b[1][2],b[2][2]
        l=[a,b]
    return l
def disp_valid(l:list,last):
    for e in l:
        valid=e!=last
        #print(f" {e},{'OP'if valid else'cl'}",end="")
    #print()
def get_next(l:list,last=None)->list:
    #print(f"finding first non {last}")
    for e in reversed(l):
        if e!=last:
            return e
    0/0

def dfs(inp0:list, goal:list)->int:
    seen={}
    #print()
    return dfs_walk(inp0,goal, seen)

def dfs_walk(inp0:list, goal:list, seen:dict, step=0)->int:
    #print(f"step={step} inp0={inp0} seen={seen}")
    #print(f"step={step} inp0={inp0} seen={len(seen)}")
    if inp0==goal:
        #print(f"found goal! seen={len(seen)}")
        return step
    sinp0=str(inp0)
    if sinp0 in seen:
        #print("already seen!")
        return 0
    seen[sinp0]=1
    out=gen(inp0)
    for inp in reversed(out):
        #print(f"step={step} walking inp={inp} seen={seen}")
        #print(f"step={step} walking inp={inp} seen={len(seen)}")
        res=dfs_walk(inp, goal, seen, step+1)
        if res>0:
            #print(f"child found returned res={res}")
            return res
        #print("first try failed")
        #0/0
    #0/0
    return 0

def idfs_walk(inp0:list, goal:list, seen:dict, depth:int, step=0)->int:
    if step>depth:
        #print("too many steps!")
        return 0
    #print(f"step={step} depth={depth} inp0={inp0} seen={len(seen)}")
    if inp0==goal:
        #print(f"found goal! seen={len(seen)}")
        return step
    sinp0=str(inp0)
    if sinp0 in seen:
        #print("already seen!")
        return 0
    seen[sinp0]=1
    out=gen(inp0)
    for inp in reversed(out):
        #print(f"step={step} walking inp={inp} seen={seen}")
        #print(f"step={step} walking inp={inp} seen={len(seen)}")
        res=idfs_walk(inp, goal, seen, depth, step+1)
        if res>0:
            #print(f"child found returned res={res}")
            return res
        #print("first try failed")
        #0/0
    #0/0
    return 0

def idfs(inp0:list, goal:list)->int:
    depth=0
    res=0
    #print()
    while True:
        seen={}
        res = idfs_walk(inp0, goal, seen, depth)
        if res>0:
            #print(f"found res={res} at depth={depth}")
            break
        depth+=1
    return res

def bfs(inp0:list, goal:list)->int:
    seen={}
    step = 0
    inps=[inp0]
    #print()
    while True:
        outs=[]
        for inp in inps:
            #print(f"eval inp={inp}")
            if inp==goal:
                #print(f"found goal! step={step}")
                return step
            sinp=str(inp)
            if sinp in seen:
                continue
            seen[sinp]=1
            outs+=gen(inp)
        #print(f"outs={outs}")
        if len(outs)==0:
            break
        inps=outs
        step+=1
    0/0

def manh(a,b):
    n=0
    if a!=b:n+=abs(b-a)
    return n
# returns manhattan distance between coords
def manhattan(coord1:tuple, coord2=(0,0))->int:
    return manh(coord1[1],coord2[1])+manh(coord1[0],coord2[0])

# returns euclidean distance between coords
def euclidean(coord1:tuple, coord2=(0,0))->int:
    a,b=coord1[0]-coord2[0],coord1[1]-coord2[1]
    return math.sqrt(a*a+b*b)

def astar(inp0:list, goal:list)->int:
    res=0
    inp=inp0
    while inp:
        outs=gen(inp)
        print(f"outs={outs}")
        mini=999999999999999999
        inp=None
        for out in outs:
            dist=getdist(out, goal)
            print(f"dist={dist}")
            if dist<mini:
                mini=dist
                inp=out
        break
    return 0

def getdist(a:list,b:list)->int:
    res=0
    h=len(a)
    w=len(a[0])
    for j in range(h):
        for i in range(w):
            e=a[j][i]
            bpos=getcoords(b,e)
            d=manhattan((i,j),bpos)
            #print(f"d={d} e={e} {(i,j)}")
            res+=d
    return res//2

def getcoords(l:list,e0:int)->(int,int):
    for j,r in enumerate(l):
        for i,e in enumerate(r):
            if e==e0:return(i,j)
    return None

import unittest
class T000(unittest.TestCase):
    def Ztest_astar_1001(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[2,0,3],[1,4,5],[8,7,6]]
        res=astar(init, goal)
        self.assertEqual(1, res)
    def Ztest_astar_0001_b(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[2,0,3],[1,4,5],[8,7,6]]
        res=astar(init, goal)
        self.assertEqual(1, res)
    def Ztest_astar_0001_a(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[1,2,3],[0,4,5],[8,7,6]]
        res=astar(init, goal)
        self.assertEqual(1, res)
    def test_astar_0000(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[0,2,3],[1,4,5],[8,7,6]]
        res=astar(init, goal)
        self.assertEqual(0, res)
    def test_getdist_0002(self):
        init=[[2,0,3],[1,4,5],[8,7,6]]
        goal=[[1,2,3],[0,4,5],[8,7,6]]
        res=getdist(init, goal)
        self.assertEqual(2, res)
    def test_getdist_0001(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[1,2,3],[0,4,5],[8,7,6]]
        res=getdist(init, goal)
        self.assertEqual(1, res)
    def test_getcoords_0000(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        self.assertEqual((0,0), getcoords(init, 0))
        self.assertEqual((0,1), getcoords(init, 1))
        self.assertEqual((1,0), getcoords(init, 2))
        self.assertEqual((2,0), getcoords(init, 3))
        self.assertEqual((1,1), getcoords(init, 4))
        self.assertEqual((2,1), getcoords(init, 5))
        self.assertEqual((2,2), getcoords(init, 6))
        self.assertEqual((1,2), getcoords(init, 7))
        self.assertEqual((0,2), getcoords(init, 8))
    def test_getdist_0000(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[0,2,3],[1,4,5],[8,7,6]]
        res=getdist(init, goal)
        self.assertEqual(0, res)
    def test_eucl_0000(self):
        self.assertEqual(0, euclidean((1,1),(1,1)))
        self.assertEqual(1, euclidean((0,0),(1,0)))
        self.assertEqual(math.sqrt(2), euclidean((0,0),(1,1)))
        self.assertEqual(math.sqrt(5), euclidean((0,0),(2,1)))
        self.assertEqual(math.sqrt(8), euclidean((0,0),(2,2)))
        self.assertEqual(5, euclidean((0,0),(4,3)))
    def test_manh_0000(self):
        self.assertEqual(0, manhattan((1,1),(1,1)))
        self.assertEqual(1, manhattan((0,0),(1,0)))
        self.assertEqual(2, manhattan((0,0),(1,1)))
        self.assertEqual(3, manhattan((0,0),(2,1)))
        self.assertEqual(4, manhattan((0,0),(2,2)))
        self.assertEqual(7, manhattan((0,0),(4,3)))
    def test_bfs_0004(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[1,2,3],[4,5,6],[8,7,0]]
        res=bfs(init, goal)
        self.assertEqual(4, res)
    def test_bfs_0002(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[2,3,0],[1,4,5],[8,7,6]]
        res=bfs(init, goal)
        self.assertEqual(2, res)
    def test_bfs_0001(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[2,0,3],[1,4,5],[8,7,6]]
        res=bfs(init, goal)
        self.assertEqual(1, res)
    def test_bfs_0000(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[0,2,3],[1,4,5],[8,7,6]]
        res=bfs(init, goal)
        self.assertEqual(0, res)
    def test_idfs_0000(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[1,2,3],[4,5,6],[8,7,0]]
        res=idfs(init, goal)
        self.assertEqual(4, res)
    def test_dfs_0004(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[1,2,3],[8,0,4],[7,6,5]]
        res=dfs(init, goal)
        self.assertEqual(32, res)
    def test_dfs_0003(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[1,2,3],[8,4,5],[7,0,6]]
        res=dfs(init, goal)
        self.assertEqual(3, res)
    def test_dfs_0002(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[1,2,3],[8,4,5],[0,7,6]]
        res=dfs(init, goal)
        self.assertEqual(2, res)
    def test_dfs_0001(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[1,2,3],[0,4,5],[8,7,6]]
        res=dfs(init, goal)
        self.assertEqual(1, res)
    def test_dfs_0000(self):
        init=[[0,2,3],[1,4,5],[8,7,6]]
        goal=[[0,2,3],[1,4,5],[8,7,6]]
        res=dfs(init, goal)
        self.assertEqual(0, res)
    def test_0000(self):
        #print()
        inp,out,last=[],[],None
        # initial input as previous output
        out+=[[ [[0,2,3],[1,4,5],[8,7,6]]]]
        # expected output reference
        outr=[  [[2,0,3],[1,4,5],[8,7,6]],
                [[1,2,3],[0,4,5],[8,7,6]],]
        inp+=[get_next(out[-1],last)];last=inp[-2]if len(inp)>1 else[]
        out+=[gen(inp[-1])];disp_valid(out[-1],last)
        self.assertEqual(outr,out[-1])

        outr=[  [[1,2,3],[4,0,5],[8,7,6]],
                [[0,2,3],[1,4,5],[8,7,6]],
                [[1,2,3],[8,4,5],[0,7,6]],]
        inp+=[get_next(out[-1],last)];last=inp[-2]if len(inp)>1 else[]
        out+=[gen(inp[-1])];disp_valid(out[-1],last)
        self.assertEqual(outr,out[-1])
        self.assertEqual(out[0][0],out[2][1])

        outr=[  [[1,2,3],[8,4,5],[7,0,6]],
                [[1,2,3],[0,4,5],[8,7,6]],]
        inp+=[get_next(out[-1],last)];last=inp[-2]if len(inp)>1 else[]
        out+=[gen(inp[-1])];disp_valid(out[-1],last)
        self.assertEqual(outr,out[-1])
        self.assertEqual(out[1][1],out[3][1])

        outr=[  [[1,2,3],[8,4,5],[0,7,6]],
                [[1,2,3],[8,4,5],[7,6,0]],
                [[1,2,3],[8,0,5],[7,4,6]],]
        inp+=[get_next(out[-1],last)];last=inp[-2]if len(inp)>1 else[]
        out+=[gen(inp[-1])];disp_valid(out[-1],last)
        self.assertEqual(outr,out[-1])

        outr=[  [[1,2,3],[0,8,5],[7,4,6]],
                [[1,2,3],[8,5,0],[7,4,6]],
                [[1,0,3],[8,2,5],[7,4,6]],
                [[1,2,3],[8,4,5],[7,0,6]],]
        inp+=[get_next(out[-1],last)];last=inp[-2]if len(inp)>1 else[]
        out+=[gen(inp[-1])];disp_valid(out[-1],last)
        self.assertEqual(outr,out[-1])
        self.assertEqual(out[3][0],out[5][3])

        outr=[  [[0,1,3],[8,2,5],[7,4,6]],
                [[1,3,0],[8,2,5],[7,4,6]],
                [[1,2,3],[8,0,5],[7,4,6]],]
        inp+=[get_next(out[-1],last)];last=inp[-2]if len(inp)>1 else[]
        out+=[gen(inp[-1])];disp_valid(out[-1],last)
        self.assertEqual(outr,out[-1])
        self.assertEqual(out[4][2],out[6][2])

        outr=[  [[1,0,3],[8,2,5],[7,4,6]],
                [[1,3,5],[8,2,0],[7,4,6]],]
        inp+=[get_next(out[-1],last)];last=inp[-2]if len(inp)>1 else[]
        out+=[gen(inp[-1])];disp_valid(out[-1],last)
        self.assertEqual(outr,out[-1])

        outr=[  [[1,3,5],[8,0,2],[7,4,6]],
                [[1,3,0],[8,2,5],[7,4,6]],
                [[1,3,5],[8,2,6],[7,4,0]],]
        inp+=[get_next(out[-1],last)];last=inp[-2]if len(inp)>1 else[]
        out+=[gen(inp[-1])];disp_valid(out[-1],last)
        self.assertEqual(outr,out[-1])

        outr=[  [[1,3,5],[8,2,6],[7,0,4]],
                [[1,3,5],[8,2,0],[7,4,6]],]
        inp+=[get_next(out[-1],last)];last=inp[-2]if len(inp)>1 else[]
        out+=[gen(inp[-1])];disp_valid(out[-1],last)
        self.assertEqual(outr,out[-1])
