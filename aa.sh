sgdisk --zap-all $1

sgdisk --new=1:0:+4M --typecode=1:EF02 $1
sgdisk --new=2:0:+200M --typecode=2:8300 $1
sgdisk --new=3:0:0 --typecode=3:8300 $1
sgdisk -p $1
sgdisk -v $1

bootpart=$1
bootpart+=2
rootpart=$1
rootpart+=3

mkfs.ext4 $bootpart
mkfs.ext4 $rootpart

mount $rootpart /mnt
mkdir /mnt/boot
mount $bootpart /mnt/boot
genfstab -U /mnt > /mnt/etc/fstab

