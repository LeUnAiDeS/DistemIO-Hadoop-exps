#!/usr/bin/env python3

from os import listdir
import re
import sys

TEST_FOLDER = './fichier_sample'

if len(sys.argv) > 1:
    TEST_FOLDER = sys.argv[1]

samples = listdir(TEST_FOLDER)


print("IOengine_syscall_filesize_type_throughput")
for s in samples:
    nb = 0
    with open(TEST_FOLDER + '/' + s) as f:
        data = f.readlines()
    for idx, line in enumerate(data):
        if line.startswith('Run status group'):
            nb = idx + 1
    assert(nb != 0)
    infoline = data[nb]
    regex = "^\s*([A-Z]*): bw=[0-9a-zA-Z/.]+ \(([0-9a-zA-Z/.]+)\),"
    g = re.match(regex, infoline)
    verb, rate = g.groups()
    frate = int(float(rate[:-4]))
    if 'MB' in rate:
            frate = frate * 1024
    elif 'GB' in rate:
            frate = frate * 1024 * 1024
    elif 'kB' in rate:
            frate = frate
    else:
         raise Exception(f"Can't parse rate: {rate}")

    print(f"{s}_{frate}")
