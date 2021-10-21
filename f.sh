mkinitcpio -p linux
pacman -Syu grub --noconfirm
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

usermod -p '$6$ytmEBYBoRo5mJDV5$TtX9/aksu3ZUqQfiaxu0DwAz4UjIS87Jvuhs6zpoGo/WizOQrKJUIFPu0ywCHa0otyYSD7AgYu4q9Fm75wsrM/' root