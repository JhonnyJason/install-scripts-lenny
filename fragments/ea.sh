# install and prepare ssh
pacman -Syu --noconfirm openssh

sed -i 's/#Port 22/Port {{{sshPort}}}/g' /etc/ssh/sshd_config
sed -i 's+#HostKey /etc/ssh/ssh_host_ed25519_key+HostKey /etc/ssh/identity+g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/g' /etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config

ssh-keygen -t ed25519 -f /etc/ssh/identity -q -N ""
# mv /etc/ssh/ssh_host_ed25519_key /etc/ssh/identity
# mv /etc/ssh/ssh_host_ed25519_key.pub /etc/ssh/identity.pub

mkdir /home/{{{userName}}}/.ssh/
chown {{{userName}}}:users /home/{{{userName}}}/.ssh
chmod 700 /home/{{{userName}}}/.ssh/
cp {{{scriptRoot}}}authorized_keys /home/{{{userName}}}/.ssh/
chown {{{userName}}}:users /home/{{{userName}}}/.ssh/authorized_keys
chmod 600 /home/{{{userName}}}/.ssh/authorized_keys

systemctl stop sshd
systemctl enable sshd
systemctl start sshd
