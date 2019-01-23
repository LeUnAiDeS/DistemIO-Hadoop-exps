#!/usr/bin/env python3

from os import listdir
import re
import sys

TEST_FOLDER = './v2'

MAX = None

if len(sys.argv) > 1:
    TEST_FOLDER = sys.argv[1]

if len(sys.argv) > 2:
    MAX = int(sys.argv[2])

samples = listdir(TEST_FOLDER)
ARR={524288: '512 KB/s',
     1048576: '1 MB/s', 
     33554432: '32 MB/s',
     67108864: '64 MB/s',
     134217728: '128 MB/s',
     536870912: '512 MB/s',
     1073741824: '1 GB/s',
     268435456:  '256 MB/s'}

print("IOengine_syscall_filesize_limitation_type_throughput_ideal")
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
    split_str = s.split('_')
    limit = int(split_str[3])
    assert(limit in ARR)
    new_limit = ARR[limit]
    ideal = int(s.split("_")[-2]) / 1024
    assert(int(ideal) == ideal)
    ideal = int(ideal)
    frate = int(float(rate[:-4]))
    if MAX and frate > MAX:
        frate = MAX
    if 'MB' in rate:
            frate = frate * 1024
    elif 'GB' in rate:
            frate = frate * 1024 * 1024
    elif 'kB' in rate:
            frate = frate
    else:
         raise Exception(f"Can't parse rate: {rate}")

    print(f"{split_str[0]}_{split_str[1]}_{split_str[2]}_{new_limit}_{split_str[4]}_{frate}_{ideal}")
