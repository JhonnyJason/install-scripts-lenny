sudo mkdir -p /var/lib/lxd/storage-pools/{{{storagePoolName}}}/containers/{{{containerName}}}/rootfs/{{{dataDirectory}}}
sudo mount --bind /home/{{{userName}}}/container-data/{{{containerName}}}	/var/lib/lxd/storage-pools/{{{storagePoolName}}}/containers/{{{containerName}}}/rootfs/{{{dataDirectory}}}
