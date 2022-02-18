pacman -Syu meilisearch --noconfirm
# get IP addresses 
ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
ip6=$(/sbin/ip -o -6 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
# configure IP address to listen to
sed -i 's/#MEILI_HTTP_ADDR=/MEILI_HTTP_ADDR='$ip4':{{{meiliport}}}/g' /etc/meilisearch.conf
# kick off the service to run
systemctl enable meilisearch
systemctl start meilisearch