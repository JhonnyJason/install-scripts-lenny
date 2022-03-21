# create the directories if they donot exist
mkdir -p /container-data/{{{containerName}}}/readonly
mkdir -p /container-data/{{{containerName}}}/writable
chmod 777 /container-data/{{{containerName}}}/writable 
# add directories as disk devices
lxc config device add {{{containerName}}} {{{readonlyDiskName}}} disk source=/container-data/{{{containerName}}}/readonly path={{{readonlyDirectory}}}
lxc config device add {{{containerName}}} {{{writableDiskName}}} disk source=/container-data/{{{containerName}}}/writable path={{{writableDirectory}}}
