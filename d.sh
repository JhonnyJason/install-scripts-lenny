# sudo must already be installed
# variable: username = lenny
# variable: password_hash = $6$WPqF0fCnyQ59ZOSb$.7OdtgSb6XzywcP/nxB4T9ChBKJTydv1.Z.eJgtKk20RpaTZvit/wbJ/Y0UOT1.OkWc.XO1tf0x3UzjP89Iyg1
groupadd users
useradd -m -g users -G wheel -s /bin/bash lenny
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
usermod -p '$6$WPqF0fCnyQ59ZOSb$.7OdtgSb6XzywcP/nxB4T9ChBKJTydv1.Z.eJgtKk20RpaTZvit/wbJ/Y0UOT1.OkWc.XO1tf0x3UzjP89Iyg1' lenny
passwd -l root
