#!/bin/bash
echo builder-container > /etc/hostname
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo 'KEYMAP=de-latin1' > /etc/vconsole.conf
echo 'FONT=lat9w-16' >> /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
pacman -Syu base-devel git --noconfirm

# # get IP addresses 
# ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
# ip6=$(/sbin/ip -o -6 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

#add user
useradd -m -G wheel -s /bin/bash builder
#adjust sudoers
sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

#add directories to be readbable outside of the container as well
mkdir -p /writable/repo-packages/aur-packages
mkdir -p /writable/repo-packages/custom-packages
mkdir -p /writable/repo-packages/meta-packages
#adjust permissions
chown -R builder:http /writable/*
chmod -R 750 /writable/*
chown builder:http /home/builder
chmod 750 /home/builder
#link it up
ln -sf /writable/repo-packages /home/builder/repo-packages

#reown terminal to builder for gpg stuff
chown builder $(tty)
#generate key without passphrase
su builder << EoI
mkdir ~/.keystuff
cd ~/.keystuff
cat >keygen <<EOF
     %echo Generating GPG Key for Builder Bot
     Key-Type: eddsa
     Key-Curve: Ed25519
     Name-Real: Lenny Builder Bot
     Name-Comment: Key for automatically signing built Packages  
     Name-Email: bots@frommelt.dev
     Expire-Date: 3y
     # Passphrase: abc
     %no-protection
     %commit
     %echo done
EOF
gpg --batch --gen-key keygen
EoI


# #install machine thingy nginx
# actually we donot need the nginx here... -> Builder Server Container
# su builder << EoI
# mkdir ~/builds
# cd ~/builds
# git clone https://github.com/JhonnyJason/machine-thingy-nginx
# cd machine-thingy-nginx
# makepkg -si --noconfirm
# sudo mkdir /etc/nginx/servers
# cd /etc/nginx/servers
# EoI

# switch package compression to heavy xz compression
sed -i 's/.pkg.tar.zst/.pkg.tar.xz/g' /etc/makepkg.conf
sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -z -9)/g' /etc/makepkg.conf
# add signing of packages
sed -i 's/!sign/sign/g' /etc/makepkg.conf
sed -i 's/#PACKAGER="John Doe <john@doe.com>"/PACKAGER="Lenny Builder Bot <bots@frommelt.dev>"/g' /etc/makepkg.conf
# use the specific key we just generated
keyId=$(su - builder -c 'gpg --list-secret-keys' | gawk '/[:alnum:]*/ {if(length($1) == 40) print$1}')
sed -i 's/#GPGKEY=""/GPGKEY="'$keyId'"/g' /etc/makepkg.conf
# let pacman trust the key
su - builder -c 'gpg --armor --export '$keyId' > ~/.keystuff/public.key'
pacman-key --add /home/builder/.keystuff/public.key
pacman-key --lsign-key $keyId

#install yay
su builder << EoI
mkdir ~/builds
cd ~/builds
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
EoI

#install aurutils
su builder << EoI
yay -Syu aurutils --noconfirm
EoI

#add repo dbs
su builder << EoI
cd ~/repo-packages/aur-packages
repo-add -s aur-packages.db.tar.xz
cd ~/repo-packages/custom-packages
repo-add -s custom-packages.db.tar.xz
cd ~/repo-packages/meta-packages
repo-add -s meta-packages.db.tar.xz
EoI

# add lines to /etc/pacman.conf for our repos
echo -e "\n[aur-packages]\nServer = file:///home/builder/repo-packages/aur-packages\n" >> /etc/pacman.conf
echo -e "\n[custom-packages]\nServer = file:///home/builder/repo-packages/custom-packages\n" >> /etc/pacman.conf
echo -e "\n[meta-packages]\nServer = file:///home/builder/repo-packages/meta-packages\n" >> /etc/pacman.conf

#update package dbs
pacman -Sy

# build and add aur-packages.
su builder << EoI
cd ~/repo-packages/aur-packages
aur sync -d aur-packages -D . --no-view yay brave-bin fonts-tlwg vscodium-bin --noconfirm --sign
EoI

# To update the aur-packages then later //to be added to the timed service
# aur-sync -d aur-packages -D . --no-view -u --sign --noconfirm

# build and add custom-packages
su builder << EoI
cd ~/builds/
git clone https://github.com/JhonnyJason/custom-packages.git custom-package-script
cd custom-package-script
./create-packages.sh
cd ~/repo-packages/custom-packages
repo-add custom-packages.db.tar.xz *.pkg.tar.xz -R -s
EoI 

# build and add meta-packages

