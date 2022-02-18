#!/bin/bash
lxc launch images:archlinux/current meilisearch-container
# create the directories if they donot exist
mkdir -p /home/lenny/container-data/meilisearch-container/readonly
mkdir -p /home/lenny/container-data/meilisearch-container/writable
chmod 777 /home/lenny/container-data/meilisearch-container/writable 
# add directories as disk devices
lxc config device add meilisearch-container readonly-disk disk source=/home/lenny/container-data/meilisearch-container/readonly path=/readonly/
lxc config device add meilisearch-container writable-disk disk source=/home/lenny/container-data/meilisearch-container/writable path=/writable/
# copy the scrupt itno the container
cp scripts/meilisearchBaseConfig.sh ~/container-data/meilisearch-container/readonly/
# execute the script
lxc exec meilisearch-container -- /readonly/meilisearchBaseConfig.sh
