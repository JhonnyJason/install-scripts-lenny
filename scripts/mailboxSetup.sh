#!/bin/bash

#format to Lenny's Standard Disk Layout
sgdisk --zap-all /dev/sda

sgdisk --new=1:0:+4M --typecode=1:EF02 /dev/sda
sgdisk --new=2:0:+200M --typecode=2:8300 /dev/sda
sgdisk --new=3:0:0 --typecode=3:8300 /dev/sda
sgdisk -p /dev/sda
sgdisk -v /dev/sda

bootpart=/dev/sda
bootpart+=2
rootpart=/dev/sda
rootpart+=3

mkfs.ext4 -F $bootpart
mkfs.ext4 -F $rootpart

mount $rootpart /mnt
mkdir /mnt/boot
mount $bootpart /mnt/boot

# install base
pacman -Syy
# might be shipped with the ISO already *smirk*
pacman -S reflector --noconfirm
reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap  /mnt base base-devel linux linux-firmware intel-ucode nano sudo openssh grub
genfstab -U /mnt > /mnt/etc/fstab

echo mailbox > /mnt/etc/hostname
echo 'LANG=en_US.UTF-8' > /mnt/etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo 'KEYMAP=de-latin1' > /mnt/etc/vconsole.conf
echo 'FONT=lat9w-16' >> /mnt/etc/vconsole.conf
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime


# add sudoable user
#arch-chroot /mnt pacman -Syu --noconfirm sudo
arch-chroot /mnt groupadd users
arch-chroot /mnt useradd -m -g users -G wheel -s /bin/bash sose
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /mnt/etc/sudoers
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /mnt/etc/sudoers
arch-chroot /mnt usermod -p '$6$WPqF0fCnyQ59ZOSb$.7OdtgSb6XzywcP/nxB4T9ChBKJTydv1.Z.eJgtKk20RpaTZvit/wbJ/Y0UOT1.OkWc.XO1tf0x3UzjP89Iyg1' sose
arch-chroot /mnt passwd -l root


# install and prepare ssh
#arch-chroot /mnt pacman -Syu --noconfirm openssh

sed -i 's/#Port 22/Port 37537/g' /mnt/etc/ssh/sshd_config
sed -i 's+#HostKey /etc/ssh/ssh_host_ed25519_key+HostKey /etc/ssh/identity+g' /mnt/etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /mnt/etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /mnt/etc/ssh/sshd_config
sed -i 's/UsePAM yes/UsePAM no/g' /mnt/etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/g' /mnt/etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /mnt/etc/ssh/sshd_config

arch-chroot /mnt ssh-keygen -t ed25519 -f /etc/ssh/identity -q -N ""
# mv /etc/ssh/ssh_host_ed25519_key /etc/ssh/identity
# mv /etc/ssh/ssh_host_ed25519_key.pub /etc/ssh/identity.pub

arch-chroot /mnt mkdir /home/sose/.ssh/
arch-chroot /mnt chown sose:users /home/sose/.ssh
arch-chroot /mnt chmod 700 /home/sose/.ssh/

# cp /readonly/authorized_keys /home/sose/.ssh/
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW7ep4Xt7PaWVoAKN2IggZiS6zAmqU2GLC7ZCB/f6Vn lenny@nova" > /mnt/home/sose/.ssh/authorized_keys

arch-chroot /mnt chown sose:users /home/sose/.ssh/authorized_keys
arch-chroot /mnt chmod 600 /home/sose/.ssh/authorized_keys

# systemctl stop sshd
arch-chroot /mnt systemctl enable sshd
# systemctl start sshd


#configure network
echo "[Match]" > /mnt/etc/systemd/network/20-wired.network
echo "Name=ens3" >> /mnt/etc/systemd/network/20-wired.network
echo "[Network]" >> /mnt/etc/systemd/network/20-wired.network
echo "DHCP=yes" >> /mnt/etc/systemd/network/20-wired.network

arch-chroot /mnt systemctl enable systemd-networkd
arch-chroot /mnt systemctl enable systemd-resolved


# Initialize Linux and make system bootable
arch-chroot /mnt mkinitcpio -p linux
#arch-chroot /mnt pacman -Syu grub --noconfirm
arch-chroot /mnt grub-install /dev/sda
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
