#!/bin/bash

path="/tmp/distem/rootfs-unique/*/home/hadoop/.ssh"

for serv in $(uniq $OAR_NODE_FILE)
do
    scp ~/.ssh/authorized_keys root@$serv:$path
    scp ~/.ssh/id_rsa* root@$serv:$path
    scp config root@$serv:$path
done
