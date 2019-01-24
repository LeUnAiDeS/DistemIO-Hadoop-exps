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
echo "+io +memory" > $MNT_PATH/cgroup.subtree_control

MEM=1073741824            #1G
echo $MEM > $MNT_PATH/$CG_NAME/memory.high

#
#echo $$ > $MNT_PATH/$CG_NAME/cgroup.procs -> fio --cgroup

#echo -e "\e[31mCurrent io controller settings:\e[0m"
#cat $MNT_PATH/$CG_NAME/io.max

#echo -e "\e[31mCurrent memory controller settings:\e[0m"
#cat $MNT_PATH/$CG_NAME/memory.high

echo -e "mPerfom Fio tests..."

limits=(33554432 67108864 134217728 536870912 1073741824 524288 1048576)
engines=(sync mmap psync pvsync pvsync2 posixaio)
filesizes=(1M 10M 256M 1024M 2048M)
patterns=(read write randread randwrite readwrite randrw)


for limit in "${limits[@]}"; do

echo $(stat -c '%t:%T' $TDISK) wbps=$limit rbps=$limit > $MNT_PATH/$CG_NAME/io.max


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
done


echo -e "End of fio tests"

echo -e "cgroup2 controllers stats:"
cat $MNT_PATH/$CG_NAME/io.stat

echo -e "Deactivate limits and umount cgroup2 fs."
echo "-io -memory" > $CGROUP_PATH/cgroup.subtree_control
umount $MNT_PATH





