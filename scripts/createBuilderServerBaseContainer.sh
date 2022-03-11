#!/bin/bash
lxc launch images:archlinux/current sparkle-container
# create the directories if they donot exist
mkdir -p /home/lenny/container-data/sparkle-container/readonly
mkdir -p /home/lenny/container-data/sparkle-container/writable
chmod 777 /home/lenny/container-data/sparkle-container/writable 
# add directories as disk devices
lxc config device add sparkle-container readonly-disk disk source=/home/lenny/container-data/sparkle-container/readonly path=/readonly/
lxc config device add sparkle-container writable-disk disk source=/home/lenny/container-data/sparkle-container/writable path=/writable/
# provide authorized public key
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW7ep4Xt7PaWVoAKN2IggZiS6zAmqU2GLC7ZCB/f6Vn lenny@nova" > /home/lenny/container-data/sparkle-container/readonly/authorized_keys
# copy the script into the container
cp scripts/builderServerBaseConfig.sh ~/container-data/sparkle-container/readonly/
# execute the script
lxc exec sparkle-container -- /readonly/builderServerBaseConfig.sh
