mkinitcpio -p linux
pacman -Syu grub --noconfirm
grub-install {{{targetDiskDevice}}}
grub-mkconfig -o /boot/grub/grub.cfg