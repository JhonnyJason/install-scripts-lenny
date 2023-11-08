#!/bin/bash

#format to Lenny's Standard Disk Layout
sgdisk --zap-all {{{targetDiskDevice}}}

sgdisk --new=1:0:+4M --typecode=1:EF02 {{{targetDiskDevice}}}
sgdisk --new=2:0:+200M --typecode=2:8300 {{{targetDiskDevice}}}
sgdisk --new=3:0:0 --typecode=3:8300 {{{targetDiskDevice}}}
sgdisk -p {{{targetDiskDevice}}}
sgdisk -v {{{targetDiskDevice}}}

bootpart={{{targetDiskDevice}}}
bootpart+=2
rootpart={{{targetDiskDevice}}}
rootpart+=3

mkfs.ext4 $bootpart
mkfs.ext4 $rootpart

mount $rootpart /mnt
mkdir /mnt/boot
mount $bootpart /mnt/boot

# install base
pacman -Syy
# might be shipped with the ISO already *smirk*
pacman -S reflector --noconfirm
reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap  /mnt {{{pacstrapPackages}}}
genfstab -U /mnt > /mnt/etc/fstab

echo {{{machineName}}} > /mnt/etc/hostname
echo 'LANG=en_US.UTF-8' > /mnt/etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo 'KEYMAP=de-latin1' > /mnt/etc/vconsole.conf
echo 'FONT=lat9w-16' >> /mnt/etc/vconsole.conf
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# add sudoable user
arch-chroot /mnt pacman -Syu --noconfirm sudo
arch-chroot /mnt groupadd users
arch-chroot /mnt useradd -m -g users -G wheel -s /bin/bash {{{userName}}}
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /mnt/etc/sudoers
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /mnt/etc/sudoers
arch-chroot /mnt usermod -p {{{userPWDHash}}} {{{userName}}}
arch-chroot /mnt passwd -l root

# install and prepare ssh
arch-chroot /mnt pacman -Syu --noconfirm openssh

sed -i 's/#Port 22/Port {{{sshPort}}}/g' /mnt/etc/ssh/sshd_config
sed -i 's+#HostKey /etc/ssh/ssh_host_ed25519_key+HostKey /mnt/etc/ssh/identity+g' /mnt/etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /mnt/etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /mnt/etc/ssh/sshd_config
sed -i 's/UsePAM yes/UsePAM no/g' /mnt/etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/g' /mnt/etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /mnt/etc/ssh/sshd_config

arch-chroot /mnt ssh-keygen -t ed25519 -f /etc/ssh/identity -q -N ""
# mv /etc/ssh/ssh_host_ed25519_key /etc/ssh/identity
# mv /etc/ssh/ssh_host_ed25519_key.pub /etc/ssh/identity.pub

arch-chroot /mnt mkdir /home/{{{userName}}}/.ssh/
arch-chroot /mnt chown {{{userName}}}:users /home/{{{userName}}}/.ssh
arch-chroot /mnt chmod 700 /home/{{{userName}}}/.ssh/

# cp /readonly/authorized_keys /home/{{{userName}}}/.ssh/
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW7ep4Xt7PaWVoAKN2IggZiS6zAmqU2GLC7ZCB/f6Vn lenny@nova" > /mnt/home/{{{userName}}}/.ssh/authorized_keys

arch-chroot /mnt chown {{{userName}}}:users /home/{{{userName}}}/.ssh/authorized_keys
arch-chroot /mnt chmod 600 /home/{{{userName}}}/.ssh/authorized_keys

# systemctl stop sshd
arch-chroot /mnt systemctl enable sshd
# systemctl start sshd


# Initialize Linux and make system bootable
arch-chroot /mnt mkinitcpio -p linux
arch-chroot /mnt pacman -Syu grub --noconfirm
arch-chroot /mnt grub-install {{{targetDiskDevice}}}
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
