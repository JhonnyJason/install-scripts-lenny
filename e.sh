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