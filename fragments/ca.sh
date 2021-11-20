pacman -Syu postgresql --noconfirm
su postgres -c 'initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data'
systemctl enable postgresql
systemctl start postgresql
