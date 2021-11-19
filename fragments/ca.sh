pacman -Syu postgresql --noconfirm

su postgres ##!! this does not work in the shell...
## now being user postgres
initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data
exit
## not being user postgres anymore
systemctl enable postgresql
systemctl start postgresql