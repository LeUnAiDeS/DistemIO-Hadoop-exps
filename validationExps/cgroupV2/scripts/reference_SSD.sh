#!/bin/bash

echo -e "mPerfom Fio tests..."

filesizes=(1M 10M 256M 1024M 2048M)
#engines=(sync mmap psync pvsync pvsync2 posixaio)
engines=(sync mmap)
#patterns=(read write randread randwrite readwrite randrw)
patterns=(read write)


for filesize in "${filesizes[@]}"; do

for engine in "${engines[@]}"; do
for pattern in "${patterns[@]}"; do


rm ../testFile*
echo -e "Syncing before starting a test (may have IO in the queue)..."
sync
echo 3 > /proc/sys/vm/drop_caches

fio --name=../testFile --size=$filesize --ioengine=$engine --rw=$pattern --buffered=1 --output=../results/$engine\_$pattern\_$filesize\_buffered

rm ../testFile*
echo -e "Syncing before starting a test (may have IO in the queue)..."
sync
echo 3 > /proc/sys/vm/drop_caches

fio --name=../testFile  --size=$filesize --ioengine=$engine --rw=$pattern --direct=1 --output=../results/$engine\_$pattern\_$filesize\_direct

done
done
done

echo -e "End of fio tests"





