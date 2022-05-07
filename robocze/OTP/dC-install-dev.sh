#!/bin/bash

#Skrypt powstał na podstawie wpisu na blogu, znajdującego się po poniższym
#adresem:
#https://www.brianlinkletter.com/2016/05/how-to-install-dcore-linux-in-a-virtual-machine/

#Wskazanie urządzenia z obrazem instalacyjnym

dCtype=$1
install_device=$2
target_device=$3
target_part="${target_device}1"
swap_device="${target_device}2"

#if [ $dCtype = "OTP" ]; then
  #Podmontowanie katalogu z rozszerzeniami
#  if ! $(mount | grep -q '\ /tmp/tce/sce\ '); then 
#    sudo mount -B /mnt/$(basename $install_device)/cde/sce /tmp/tce/sce
#  fi
#fi

#Wyzerowanie pierwszego MB wybranego dysku
sudo dd if=/dev/zero bs=1M of=$target_device count=1

#Instalacja sfdisk
#if [ $dCtype = "dCore" ]; then
#  if $(grep -q '\(wheezy\|jessie\|stretch\)' /usr/share/doc/tc/repo.txt); then
#    sce-import util-linux;
#  else
#    sce-import fdisk;
#  fi
#fi
#if [ $dCtype = "dCore" ]; then
#  if $(grep -q '\(wheezy\|jessie\|stretch\)' /usr/share/doc/tc/repo.txt); then 
#    sce-load util-linux;
#  else
#    sce-load fdisk;
#  fi 
#else
#  sce-load fdisk
#fi

#Przygotowanie i instalacja rozszerzenia z pakietami niezbędnymi do
#instalacji
cat > /tmp/install_prep << EOF
parted
e2fsprogs
extlinux
EOF

sce-import -lb /tmp/install_prep;
sce-load install_prep;
	
#Partycjonowanie dysku
#echo "label: dos" | sudo sfdisk $target_device
#echo ",,L,*" | sudo sfdisk $target_device
sudo parted $target_device mklabel msdos

if [ $dCtype = "OTP" ]; then
  disk_size=$(sudo fdisk -l $target_device | sed -nr 's/.+tów\:\ ([0-9]*[^,]).+/\1/p');
else
  if $(grep -q '\(wheezy\|trusty\)' /usr/share/doc/tc/repo.txt); then
    disk_size=$(sudo fdisk -l $target_device | sed -nr 's/.+\,\ ([0-9]*[^,])\ bytes$/\1/p');
  else
    disk_size=$(sudo fdisk -l $target_device | sed -nr 's/.+\,\ ([0-9]*[^,])\ bytes.+/\1/p');
  fi
fi
disk_sizeMB=$((disk_size / 1024000));
root_size=$(((70 * disk_sizeMB) / 100));
swap_start=$((root_size + 1));
sudo parted $target_device mkpart primary ext4 1 $root_size;
sudo parted $target_device mkpart primary linux-swap $swap_start $disk_sizeMB;
sudo parted $target_device set 1 boot on;


#Formatowanie partycji oraz rebuild fstab
sudo mkfs.ext4 ${target_device}1
sudo mkswap ${target_device}2
sleep 2
sudo rebuildfstab

#Montowanie głównego systemu plików oraz obrazu instalacyjnego
mount_point="/mnt/$(basename $target_part)"

sudo mount $mount_point
sudo mount $install_device /mnt/$(basename $install_device)

#Tworzenie niezbędnych katalogów
sudo mkdir -p ${mount_point}/boot/extlinux

#Kopiowanie jądra oraz initrd
sudo cp -p /mnt/$(basename $install_device)/boot/* ${mount_point}/boot/

#Ustawienie etykiety dla partycji
if [ $dCtype = "OTP" ]; then
	sudo e2label ${target_part} "OTP"
else
	sudo e2label ${target_part} "dCore"
fi

#Instalacja plików extlinux na dysku
sudo extlinux --install ${mount_point}/boot/extlinux

#Instalacja rekordu rozruchowego na dysku
if $(grep -q '\(wheezy\|trusty\)' /usr/share/doc/tc/repo.txt); then
  sudo dd if=/usr/lib/extlinux/mbr.bin of=${target_device}
else
  sudo dd if=/usr/lib/EXTLINUX/mbr.bin of=${target_device}
fi

#Tworzenie pliku konfiguracyjnego programu rozruchowego
kernel_filename=$(basename /mnt/$(basename $install_device)/boot/vmlinuz*);
initrd_filename=$(basename /mnt/$(basename $install_device)/boot/*.gz);

if [ $dCtype = "OTP" ]; then
	sudo cat > $HOME/extlinux.conf << EOF
default OTP
label OTP
kernel /boot/$kernel_filename
append initrd=/boot/$initrd_filename tce=$(basename $mount_point) quiet desktop=icewm host=otp lang=pl_PL.UTF-8
EOF
else
	sudo cat > $HOME/extlinux.conf <<EOF
default dCore
label dCore
kernel /boot/$kernel_filename
append initrd=/boot/$initrd_filename tce=$(basename $mount_point) quiet
EOF
fi
sudo cp $HOME/extlinux.conf ${mount_point}/boot/extlinux

cat ${mount_point}/boot/extlinux/extlinux.conf;

/usr/bin/tce-setdrive

if [ $dCtype = "OTP" ]; then
	sudo cp -rvv /mnt/$(basename ${install_device})/cde/* ${mount_point}/tce
fi

echo "$dCtype został poprawnie zainstalowany, teraz można uruchomić komputer ponownie.";
