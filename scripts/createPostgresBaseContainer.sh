#!/bin/bash
lxc launch images:archlinux/current postgres-container
sudo mkdir -p /var/lib/lxd/storage-pools/poolone/containers/postgres-container/rootfs/data/
sudo mount --bind /home/lenny/container-data/postgres-container	/var/lib/lxd/storage-pools/poolone/containers/postgres-container/rootfs/data/
cp scripts/postgresqlBaseConfig.sh ~/container-data/postgres-container/
lxc exec postgres-container -- /data/postgresqlBaseConfig.sh
