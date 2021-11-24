#!/bin/bash
lxc launch images:archlinux/current postgres-container
# create the directories if they donot exist
mkdir -p /home/lenny/container-data/postgres-container/readonly
mkdir -p /home/lenny/container-data/postgres-container/writable
chmod 777 /home/lenny/container-data/postgres-container/writable 
# add directories as disk devices
lxc config device add postgres-container readonly-disk disk source=/home/lenny/container-data/postgres-container/readonly path=/readonly/
lxc config device add postgres-container writable-disk disk source=/home/lenny/container-data/postgres-container/writable path=/writable/
# copy the scrupt itno the container
cp scripts/postgresqlBaseConfig.sh ~/container-data/postgres-container/readonly/
# execute the script
lxc exec postgres-container -- /readonly/postgresqlBaseConfig.sh
