#!/bin/bash
echo postgres-container > /etc/hostname
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo 'KEYMAP=de-latin1' > /etc/vconsole.conf
echo 'FONT=lat9w-16' >> /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
pacman -Syu postgresql --noconfirm
su postgres -c 'initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data'
systemctl enable postgresql
systemctl start postgresql
## here create the desired users and tables for the postgresql db
# TODO