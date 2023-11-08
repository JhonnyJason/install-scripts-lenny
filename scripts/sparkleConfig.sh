#!/bin/bash
echo sparkle > /etc/hostname
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo 'KEYMAP=de-latin1' > /etc/vconsole.conf
echo 'FONT=lat9w-16' >> /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
# add suduable user
pacman -Syu --noconfirm sudo
groupadd users
useradd -m -g users -G wheel -s /bin/bash sose
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
usermod -p '$6$WPqF0fCnyQ59ZOSb$.7OdtgSb6XzywcP/nxB4T9ChBKJTydv1.Z.eJgtKk20RpaTZvit/wbJ/Y0UOT1.OkWc.XO1tf0x3UzjP89Iyg1' sose
passwd -l root
# install and prepare ssh
pacman -Syu --noconfirm openssh

sed -i 's/#Port 22/Port 37537/g' /etc/ssh/sshd_config
sed -i 's+#HostKey /etc/ssh/ssh_host_ed25519_key+HostKey /etc/ssh/identity+g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/g' /etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config

ssh-keygen -t ed25519 -f /etc/ssh/identity -q -N ""
# mv /etc/ssh/ssh_host_ed25519_key /etc/ssh/identity
# mv /etc/ssh/ssh_host_ed25519_key.pub /etc/ssh/identity.pub

mkdir /home/sose/.ssh/
chown sose:users /home/sose/.ssh
chmod 700 /home/sose/.ssh/
cp ./authorized_keys /home/sose/.ssh/
chown sose:users /home/sose/.ssh/authorized_keys
chmod 600 /home/sose/.ssh/authorized_keys

systemctl stop sshd
systemctl enable sshd
systemctl start sshd
# install and prepare lxd
pacman -Syu --noconfirm lxd

systemctl start lxd
touch /etc/lxc/default.conf
echo "lxc.idmap = u 0 100000 65536000" >> /etc/lxc/default.conf
echo "lxc.idmap = g 0 100000 65536000" >> /etc/lxc/default.conf

echo "root:100000:65536000" > /etc/subuid
echo "root:100000:65536000" > /etc/subgid

cat <<EOF | lxd init --preseed
config: {}
networks:
- config:
    ipv4.address: auto
    ipv4.nat: "true"
    ipv6.address: none
  description: ""
  name: lxdbr0
  type: bridge
  project: default
storage_pools:
- config: {}
  description: ""
  name: poolone
  driver: dir
profiles:
- config:
    security.idmap.isolated: "true"
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: poolone
      type: disk
  name: default
  
projects: []
cluster: null
EOF

usermod -a -G lxd sose

# # get IP addresses 
# ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
# ip6=$(/sbin/ip -o -6 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

# #add user
# useradd -m -G wheel -s /bin/bash sose
# #adjust sudoers
# sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

# #add directories to be readbable outside of the container as well
# mkdir -p /writable/repo-packages/aur-packages
# mkdir -p /writable/repo-packages/custom-packages
# mkdir -p /writable/repo-packages/meta-packages
# #adjust permissions
# chown -R builder:http /writable/*
# chmod -R 750 /writable/*
# chown builder:http /home/sose
# chmod 750 /home/sose
# #link it up
# ln -sf /writable/repo-packages /home/sose/repo-packages

# #reown terminal to builder for gpg stuff
# chown sose $(tty)
# #generate key without passphrase
# su sose << EoI
# mkdir ~/.keystuff
# cd ~/.keystuff
# cat >keygen <<EOF
#      %echo Generating GPG Key for Builder Bot
#      Key-Type: eddsa
#      Key-Curve: Ed25519
#      Name-Real: Lenny Builder Bot
#      Name-Comment: Key for automatically signing built Packages  
#      Name-Email: bots@frommelt.dev
#      Expire-Date: 3y
#      # Passphrase: abc
#      %no-protection
#      %commit
#      %echo done
# EOF
# gpg --batch --gen-key keygen
# EoI


# # #install machine thingy nginx
# # actually we donot need the nginx here... -> Builder Server Container
# # su sose << EoI
# # mkdir ~/builds
# # cd ~/builds
# # git clone https://github.com/JhonnyJason/machine-thingy-nginx
# # cd machine-thingy-nginx
# # makepkg -si --noconfirm
# # sudo mkdir /etc/nginx/servers
# # cd /etc/nginx/servers
# # EoI

# # switch package compression to heavy xz compression
# sed -i 's/.pkg.tar.zst/.pkg.tar.xz/g' /etc/makepkg.conf
# sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -z -9)/g' /etc/makepkg.conf
# # add signing of packages
# sed -i 's/!sign/sign/g' /etc/makepkg.conf
# sed -i 's/#PACKAGER="John Doe <john@doe.com>"/PACKAGER=" <>"/g' /etc/makepkg.conf
# # use the specific key we just generated
# keyId=$(su - builder -c 'gpg --list-secret-keys' | gawk '/[:alnum:]*/ {if(length($1) == 40) print$1}')
# sed -i 's/#GPGKEY=""/GPGKEY="'$keyId'"/g' /etc/makepkg.conf
# # let pacman trust the key
# su - builder -c 'gpg --armor --export '$keyId' > ~/.keystuff/public.key'
# pacman-key --add /home/sose/.keystuff/public.key
# pacman-key --lsign-key $keyId

# #install yay
# su sose << EoI
# mkdir ~/builds
# cd ~/builds
# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si --noconfirm
# EoI

# #install aurutils
# su sose << EoI
# yay -Syu aurutils --noconfirm
# EoI

# #add repo dbs
# su sose << EoI
# cd ~/repo-packages/aur-packages
# repo-add -s aur-packages.db.tar.xz
# cd ~/repo-packages/custom-packages
# repo-add -s custom-packages.db.tar.xz
# cd ~/repo-packages/meta-packages
# repo-add -s meta-packages.db.tar.xz
# EoI

# # add lines to /etc/pacman.conf for our repos
# echo -e "\n[aur-packages]\nServer = file:///home/sose/repo-packages/aur-packages\n" >> /etc/pacman.conf
# echo -e "\n[custom-packages]\nServer = file:///home/sose/repo-packages/custom-packages\n" >> /etc/pacman.conf
# echo -e "\n[meta-packages]\nServer = file:///home/sose/repo-packages/meta-packages\n" >> /etc/pacman.conf

# #update package dbs
# pacman -Sy

# # build and add aur-packages.
# su sose << EoI
# cd ~/repo-packages/aur-packages
# aur sync -d aur-packages -D . --no-view  --noconfirm --sign
# EoI

# # To update the aur-packages then later //to be added to the timed service
# # aur-sync -d aur-packages -D . --no-view -u --sign --noconfirm

# # build and add custom-packages
# su sose << EoI
# cd ~/builds/
# git clone https://github.com/JhonnyJason/custom-packages.git custom-package-script
# cd custom-package-script
# ./create-packages.sh
# cd ~/repo-packages/custom-packages
# repo-add custom-packages.db.tar.xz *.pkg.tar.xz -R -s
# EoI 

# # build and add meta-packages

