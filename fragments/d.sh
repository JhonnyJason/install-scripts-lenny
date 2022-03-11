# add suduable user
pacman -Syu --noconfirm sudo
groupadd users
useradd -m -g users -G wheel -s /bin/bash {{{userName}}}
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
usermod -p {{{userPWDHash}}} {{{userName}}}
passwd -l root
