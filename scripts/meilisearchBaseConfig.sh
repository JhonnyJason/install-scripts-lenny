#!/bin/bash
echo meilisearch-container > /etc/hostname
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo 'KEYMAP=de-latin1' > /etc/vconsole.conf
echo 'FONT=lat9w-16' >> /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
pacman -Syu meilisearch --noconfirm
# get IP addresses 
ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
ip6=$(/sbin/ip -o -6 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
# configure IP address to listen to
sed -i 's/#MEILI_HTTP_ADDR=/MEILI_HTTP_ADDR='$ip4':7700/g' /etc/meilisearch.conf
# kick off the service to run
systemctl enable meilisearch
systemctl start meilisearch