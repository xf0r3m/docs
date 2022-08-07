#!/bin/bash

# Setting timezone -> Europe/Warsaw
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime;

# Setting locales to generate
sed -i '/^#pl_PL.UTF-8 UTF-8/s/#//' /etc/locale.gen;
locale-gen;

# Setting LANG variable in /etc/locale.conf
echo "LANG=pl_PL.UTF-8" > /etc/locale.conf;

# Setting displaying polish signs in virtual console:
echo "KEYMAP=pl" > /etc/vconsole.conf;
echo "FONT=lat2-16" >> /etc/vconsole.conf;
echo "FONTMAP=8859-2" >> /etc/vconsole.conf;

# Setting hostname based on release date new Arch Linux version.
# Now is: 2022.08.05 so hostname will be: arch805.
echo "arch805" > /etc/hostname;

# Enabling Network Manager unit.
systemctl enable NetworkManager.service;

# Setting root password:
passwd root;

# Create user account and set password for him.
useradd -m xf0r3m;
passwd xf0r3m;

# Instalation of sudo and increasing persmissions of new created user.
pacman -Sy sudo;
echo "xf0r3m ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers;

echo "Now the chroot part is over.";
echo "After you will get fresh installed system, log in to the created user";
echo "and run install.sh file in archflux directory.";
echo "If you need, make other chroot-installatio tasks";
