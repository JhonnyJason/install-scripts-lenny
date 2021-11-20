#!/bin/bash
sudo umount /var/lib/lxd/storage-pools/poolone/containers/postgres-container/rootfs/data/
lxc delete postgres-container --force