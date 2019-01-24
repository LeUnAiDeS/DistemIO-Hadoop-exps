#!/bin/bash

MNT_PATH=/tmp/blkcg_test
MEM_PATH=/tmp/memcg_test
CG_NAME=group_test
DISK=sda
TDISK=/dev/$DISK


echo -e "Current I/O scheduler selected:"

cat /sys/block/$DISK/queue/scheduler

mkdir -p $MNT_PATH
mkdir -p $MEM_PATH
mount -t cgroup -o blkio none $MNT_PATH
mount -t cgroup -o memory none $MEM_PATH

mkdir -p $MNT_PATH/$CG_NAME
mkdir -p $MEM_PATH/$CG_NAME
 
MN=$(stat -c '%t:%T' $TDISK)

WP=$MNT_PATH/$CG_NAME/blkio.throttle.write_bps_device
RP=$MNT_PATH/$CG_NAME/blkio.throttle.read_bps_device


echo $$ > $MNT_PATH/$CG_NAME/tasks
echo $$ > $MEM_PATH/$CG_NAME/tasks


echo -e "Perfom Fio tests.."


filesizes=(1M 10M 100M 1024M)
limits=(33554432 67108864 134217728 536870912 1073741824 524288 1048576)
engines=(sync mmap psync pvsync pvsync2 posixaio)
#patterns=(read write randread randwrite readwrite randrw)
patterns=(read write)

for filesize in "${filesizes[@]}"; do
for limit in "${limits[@]}"; do
for engine in "${engines[@]}"; do
for pattern in "${patterns[@]}"; do


# preparer la limits
echo $MN $limit > $WP
echo $MN $limit > $RP
#Try to limit page cache size -> supposed to be uneffective
echo $limit > $MEM_PATH/$CG_NAME/memory.soft_limit_in_bytes
#



rm ../testFile*
echo -e "Syncing before starting a test (may have IO in the queue)..."
sync
echo 3 > /proc/sys/vm/drop_caches

fio global.fio --name=../testFile --size=$filesize --ioengine=$engine --rw=$pattern --buffered=1 --output=../results/$engine\_$pattern\_$filesize\_$limit\_buffered

rm ../testFile*
echo -e "Syncing before starting a test (may have IO in the queue)... "
sync
echo 3 > /proc/sys/vm/drop_caches

fio global.fio  --name=../testFile  --size=$filesize --ioengine=$engine --rw=$pattern --direct=1 --output=../results/$engine\_$pattern\_$filesize\_$limit\_direct

done
done
done
done

echo -e "End of fio tests"

echo -e "Deactivate limits and umount cgroup1 fs.."
echo $MN 0 > $WP
echo $MN 0 > $RP

umount $MNT_PATH
umount $MEM_PATH




