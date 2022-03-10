#!/bin/bash
lxc launch images:archlinux/current builder-container
# create the directories if they donot exist
mkdir -p /home/lenny/container-data/builder-container/readonly
mkdir -p /home/lenny/container-data/builder-container/writable
chmod 777 /home/lenny/container-data/builder-container/writable 
# add directories as disk devices
lxc config device add builder-container readonly-disk disk source=/home/lenny/container-data/builder-container/readonly path=/readonly/
lxc config device add builder-container writable-disk disk source=/home/lenny/container-data/builder-container/writable path=/writable/
# copy the script into the container
cp scripts/builderBaseConfig.sh ~/container-data/builder-container/readonly/
# execute the script
lxc exec builder-container -- /readonly/builderBaseConfig.sh
