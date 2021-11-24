# create the directories if they donot exist
mkdir -p /home/{{{userName}}}/container-data/{{{containerName}}}/readonly
mkdir -p /home/{{{userName}}}/container-data/{{{containerName}}}/writable
chmod 777 /home/{{{userName}}}/container-data/{{{containerName}}}/writable 
# add directories as disk devices
lxc config device add {{{containerName}}} {{{readonlyDiskName}}} disk source=/home/{{{userName}}}/container-data/{{{containerName}}}/readonly path={{{readonlyDirectory}}}
lxc config device add {{{containerName}}} {{{writableDiskName}}} disk source=/home/{{{userName}}}/container-data/{{{containerName}}}/writable path={{{writableDirectory}}}
