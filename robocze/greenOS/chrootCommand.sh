#!/bin/bash

dhclient $3;

apt update;

ln -s /etc/dpkg/origins/greenos /etc/dpkg/origins/default;

dpkg-reconfigure tzdata;

apt -y install locales;
dpkg-reconfigure locales;
apt -y install keyboard-configuration console-setup;

apt -y install linux-image-amd64 firmware-linux firmware-linux-free firmware-linux-nonfree;

tasksel install standard;

passwd;

apt -y install grub2
grub-install $1;
update-grub

apt-get clean
