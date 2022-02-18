pacman -Syu meilisearch --noconfirm
#get 
ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
ip6=$(/sbin/ip -o -6 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
sed -i 's/#MEILI_HTTP_ADDR=/MEILI_HTTP_ADDR='$ip4':{{{meiliport}}}/g' /etc/meilisearch.conf

systemctl enable meilisearch
systemctl start meilisearch