#!/bin/bash

MNT_PATH=/tmp/cg2
CG_NAME=group
DISK=sda
TDISK=/dev/$DISK



echo -e "\e[31mCurrent I/O scheduler selected\e[0m:"

cat /sys/block/$DISK/queue/scheduler

mkdir -p $MNT_PATH
mount -t cgroup2 none $MNT_PATH
mkdir -p $MNT_PATH/$CG_NAME
echo "+memory" > $MNT_PATH/cgroup.subtree_control

MEM=134217728   #128M
echo $MEM > $MNT_PATH/$CG_NAME/memory.high

#
#echo $$ > $MNT_PATH/$CG_NAME/cgroup.procs -> fio --cgroup

#echo -e "\e[31mCurrent io controller settings:\e[0m"
#cat $MNT_PATH/$CG_NAME/io.max

#echo -e "\e[31mCurrent memory controller settings:\e[0m"
#cat $MNT_PATH/$CG_NAME/memory.high

echo -e "mPerfom Fio tests..."

filesizes=(1M 10M 64M 128M 256M)
#engines=(sync mmap psync pvsync pvsync2 posixaio)
engines=(sync mmap)
#patterns=(read write randread randwrite readwrite randrw)
patterns=(read write)

for filesize in "${filesizes[@]}"; do
for engine in "${engines[@]}"; do
for pattern in "${patterns[@]}"; do

#preparing the limitation


rm ../testFile*
echo -e "Syncing before starting a test (may have IO in the queue)..."
sync
echo 3 > /proc/sys/vm/drop_caches

fio --name=../testFile --cgroup=$CG_NAME --size=$filesize --ioengine=$engine --rw=$pattern --buffered=1 --output=../results/$engine\_$pattern\_$filesize\_$limit\_buffered

rm ../testFile*
echo -e "Syncing before starting a test (may have IO in the queue)..."
sync
echo 3 > /proc/sys/vm/drop_caches

fio --name=../testFile  --cgroup=$CG_NAME --size=$filesize --ioengine=$engine --rw=$pattern --direct=1 --output=../results/$engine\_$pattern\_$filesize\_$limit\_direct

done
done
done

echo -e "End of fio tests"

echo -e "cgroup2 controllers stats:"
cat $MNT_PATH/$CG_NAME/io.stat

echo -e "Deactivate limits and umount cgroup2 fs."
echo "-io -memory" > $CGROUP_PATH/cgroup.subtree_control
umount $MNT_PATH





