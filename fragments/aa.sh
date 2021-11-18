sgdisk --zap-all {{targetDiskDevice}}

sgdisk --new=1:0:+4M --typecode=1:EF02 {{targetDiskDevice}}
sgdisk --new=2:0:+200M --typecode=2:8300 {{targetDiskDevice}}
sgdisk --new=3:0:0 --typecode=3:8300 {{targetDiskDevice}}
sgdisk -p {{targetDiskDevice}}
sgdisk -v {{targetDiskDevice}}

bootpart={{targetDiskDevice}}
bootpart+=2
rootpart={{targetDiskDevice}}
rootpart+=3

mkfs.ext4 $bootpart
mkfs.ext4 $rootpart

mount $rootpart /mnt
mkdir /mnt/boot
mount $bootpart /mnt/boot



