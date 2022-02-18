# install base
pacman -Syy
# might be shipped with the ISO already *smirk*
pacman -S reflector --noconfirm
reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap  {{{pacstrapPackages}}}
genfstab -U /mnt > /mnt/etc/fstab
