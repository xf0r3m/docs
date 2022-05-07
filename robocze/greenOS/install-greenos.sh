#!/bin/bash

mode=$1;
disk=$2;
debian_mirror=$3;
rootfs_source="https://files.morketsmerke.net";
net_iface=$4;
hostname=$5;
username=$6;

fdisk $disk;

mkfs.ext4 ${disk}1
mkswap ${disk}2

mount ${disk}1 /mnt
swapon ${disk}2

#apt update && apt -y install debootstrap;

#debootstrap --arch amd64 buster /mnt $debian_mirror;

wget ${rootfs_source}/rootfs.tgz

tar -xzvf rootfs.tgz -C /mnt

echo -e "UUID=$(blkid | grep "${disk}1" | cut -d '"' -f 2)\t/\text4\tdefaults\t1\t1" > /mnt/etc/fstab;
echo -e "UUID=$(blkid | grep "${disk}2" | cut -d '"' -f 2)\tnone\tswap\tsw\t0\t0" >> /mnt/etc/fstab;

echo "deb $debian_mirror buster main contrib non-free" > /mnt/etc/apt/sources.list
echo "deb-src $debian_mirror buster main contrib non-free" >> /mnt/etc/apt/sources.list
echo >> /mnt/etc/apt/sources.list;
echo "deb $debian_mirror buster-updates main contrib non-free" >> /mnt/etc/apt/sources.list
echo "deb-src $debian_mirror buster-updates main contrib non-free" >> /mnt/etc/apt/sources.list
echo >> /mnt/etc/apt/sources.list
echo "deb http://security.debian.org/ buster/updates main contrib non-free" >> /mnt/etc/apt/sources.list;
echo "deb-src http://security.debian.org/ buster/updates main contrib non-free" >> /mnt/etc/apt/sources.list;

echo "auto lo" > /mnt/etc/network/interfaces;
echo "iface lo inet loopback" >> /mnt/etc/network/interfaces;
echo >> /mnt/etc/network/interfaces;
echo "auto $net_iface" >> /mnt/etc/network/interfaces;
echo "iface $net_iface inet dhcp" >> /mnt/etc/network/interfaces;

echo "$hostname" > /mnt/etc/hostname;

echo -e "127.0.1.1\t$hostname" >> /mnt/etc/hosts;

#/mnt/etc/issue:
echo "greenOS GNU/Linux 1 \n \l" > /mnt/etc/issue;

#/mnt/etc/issue.net:
echo "greenOS GNU/Linux 1" > /mnt/etc/issue.net;

rm /mnt/etc/dpkg/origins/default;
#/mnt/etc/dpkg/origins/greenos:
echo "Vendor: greenOS" > /mnt/etc/dpkg/origins/greenos;
echo "Vendor-URL: https://morketsmerke.net/site/greenos" >> /mnt/etc/dpkg/origins/greenos;
echo "Bugs: debbugs://bugs.morketsmerke.net" >> /mnt/etc/dpkg/origins/greenos;
# ln -s /etc/dpkg/origins/greenos /mnt/dpkg/origins/default; -> przeniesiono do chrootCommand.sh

#/mnt/usr/lib/os-release:
echo 'PRETTY_NAME="greenOS GNU/Linux 1 (first)"' > /mnt/usr/lib/os-release;
echo 'NAME="greenOS GNU/Linux"' >> /mnt/usr/lib/os-release;
echo 'VERSION_ID="1"' >> /mnt/usr/lib/os-release;
echo 'VERSION="1 (first)"' >> /mnt/usr/lib/os-release;
echo 'VERSION_CODENAME=first"' >> /mnt/usr/lib/os-release;
echo 'ID=greenos' >> /mnt/usr/lib/os-release;
echo 'HOME_URL="https://morketsmerke.net/site/greenos"' >> /mnt/usr/lib/or-release;
echo 'SUPPORT_URL="https://morketsmerke.net/site/greenos/support"' >> /mnt/usr/lib/os-release;
echo 'BUG_REPORT_URL="https://bugs.morketsmerke.net"' >> /mnt/usr/lib/os-release;

#/mnt/usr/share/base-files/motd:
sed -i 's/Debian/greenOS/g' /mnt/usr/share/base-files/motd;

#/mnt/etc/motd:
sed -i 's/Debian/greenOS/g' /mnt/etc/motd;

for i in /dev /dev/pts /proc /sys /run; do mount -B $i /mnt$i; done
# W przypadku problemu z EFI vars, to na obrazie należy wylistować katalog
# /sys/firmware/efi/efivars, jeśli nie jest pusty to należy go ręcznie
# zamonotwać:
# mount -B /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars;

if [ "$mode" = "desktop" ]; then
  cp chrootCommand-desktop.sh /mnt/chrootCommand-desktop.sh;

  mkdir /mnt/usr/share/artwork;
  cp greenos_wallpaper.png /mnt/usr/share/artwork;
  cp icewm.xpm /mnt/usr/share/artwork;
 
  cp os-depends.sh /mnt/root;
  
  chroot /mnt /bin/bash chrootCommand-desktop.sh $disk $username $net_iface;
  rm /mnt/chrootCommand-desktop.sh;
elif [ "$mode" = "server" ]; then 
  cp chrootCommand-server.sh /mnt/chrootCommand-server.sh;
  
  chroot /mnt /bin/bash chrootCommand-server.sh $disk $username $net_iface;
  rm /mnt/chrootCommand-server.sh;
fi

umount -R /mnt/dev/pts;
umount -R /mnt/dev;
umount -R /mnt/proc;
umount -R /mnt/sys;
umount -R /mnt/run;
umount -R /mnt;

echo "[*] Installation complete, reboot and check is everything all right.";
