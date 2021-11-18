pacman -Syy
pacman -S reflector --noconfirm
reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap  {{pacstrapPackages}}
genfstab -U /mnt > /mnt/etc/fstab

