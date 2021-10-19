#!/bin/bash
echo 'machinetwo' > /etc/hostname
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo 'KEYMAP=de-latin1' > /etc/vconsole.conf
echo 'FONT=lat9w-16' >> /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
# sudo must already be installed
# variable: username = lenny
# variable: password_hash = $6$WPqF0fCnyQ59ZOSb$.7OdtgSb6XzywcP/nxB4T9ChBKJTydv1.Z.eJgtKk20RpaTZvit/wbJ/Y0UOT1.OkWc.XO1tf0x3UzjP89Iyg1
groupadd users
useradd -m -g users -G wheel -s /bin/bash lenny
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
usermod -p '$6$WPqF0fCnyQ59ZOSb$.7OdtgSb6XzywcP/nxB4T9ChBKJTydv1.Z.eJgtKk20RpaTZvit/wbJ/Y0UOT1.OkWc.XO1tf0x3UzjP89Iyg1' lenny
passwd -l root
# variable: port
pacman -Syu --noconfirm openssh

sed -i 's/#Port 22/Port 37507/g' /etc/ssh/sshd_config
sed -i 's+#HostKey /etc/ssh/ssh_host_ed25519_key+HostKey /etc/ssh/identity+g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/g' /etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config

mv /etc/ssh/ssh_host_ed25519_key /etc/ssh/identity
mv /etc/ssh/ssh_host_ed25519_key.pub /etc/ssh/identity.pub

mkdir /home/lenny/.ssh/
chown lenny:users /home/lenny/.ssh
chmod 700 /home/lenny/.ssh/
cp authorized_keys /home/lenny/.ssh/
chown lenny:users /home/lenny/.ssh/authorized_keys
chmod 600 /home/lenny/.ssh/authorized_keys

systemctl stop sshd
systemctl enable sshd
systemctl start sshd