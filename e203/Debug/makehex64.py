#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

from sys import argv
import sys
import os

if 'linux' in sys.platform:             #linux environment
    binfile = os.getcwd() + "/" + argv[1]
else:                                   #windows environment
    binfile = os.getcwd() + "\\" + argv[1]

print("input file = %s" %binfile)

with open(binfile, "rb") as f:
    bindata = f.read()

#assert len(bindata) % 4 == 0

fout = open("ram.hex", "w")

for i in range(len(bindata) // 8):
    if i < len(bindata) // 8:
        w = bindata[8*i : 8*i+8]
        print("%02x%02x%02x%02x%02x%02x%02x%02x" % (w[7], w[6], w[5], w[4],w[3], w[2], w[1], w[0]), file = fout)
    else:
        print("0")
