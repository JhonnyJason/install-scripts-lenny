pacman -Syy
pacman -S reflector --noconfirm
reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel linux linux-firmware dhcpcd nano intel-ucode
genfstab -U /mnt > /mnt/etc/fstab

