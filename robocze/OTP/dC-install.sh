#!/bin/bash


#Wskazanie urządzenia z obrazem instalacyjnym
dCtype=$1
install_device=$2
target_device=$3
target_part="${target_device}1"

#Instalacja sfdisk
sce-import fdisk
sce-load fdisk
	
#Partycjonowanie dysku
echo "label: dos" | sudo sfdisk $target_device
echo ",,L,*" | sudo sfdisk $target_device

#Formatowanie partycji oraz rebuild fstab
sudo mkfs.ext4 ${target_device}1
sudo rebuildfstab

#Montowanie głównego systemu plików oraz obrazu instalacyjnego

mount_point="/mnt/$(basename $target_part)"

sudo mount $mount_point
sudo mount $install_device /mnt/$(basename $install_device)

#Tworzenie niezbędnych katalogów
sudo mkdir -p ${mount_point}/boot/extlinux

#Kopiowanie jądra oraz initrd
sudo cp -p /mnt/$(basename $install_device)/boot/* ${mount_point}/boot/

#Instalacja e2fsprogs
sce-import e2fsprogs
sce-load e2fsprogs

#Ustawienie etykiety dla partycji
if [ $dCtype = "OTP" ]; then
	sudo e2label "OTP" ${target_part}
else
	sudo e2label "dCore" ${target_part}
fi

#Instalacja extlinux
sce-import extlinux
sce-load extlinux

#Instalacja plików extlinux na dysku
sudo extlinux --install ${mount_point}/boot/extlinux

#Instalacja rekordu rozruchowego na dysku
sudo dd if=/usr/lib/EXTLINUX/mbr.bin of=${target_device}

#Tworzenie pliku konfiguracyjnego programu rozruchowego
if [ $dCtype = "OTP" ]; then
	sudo cat > $HOME/extlinux.conf << EOF
default OTP
label OTP
kernel /boot/vmlinuzbionic
append initrd=/boot/OTP.gz tce=$(basename $mount_point) quiet desktop=icewm host=otp
EOF
else
	sudo cat > $HOME/extlinux.conf <<EOF
default dCore
label dCore
kernel /boot/vmlinuzbionic
append initrd=/boot/dCorebionic.gz tce=$(basename $mount_point) quiet
EOF
fi
sudo cp $HOME/extlinux.conf ${mount_point}/boot/extlinux

/usr/bin/tce-setdrive

if [ $dCtype = "OTP" ]; then
	sudo cp -rvv /mnt/$(basename ${install_device})/cde/* ${mount_point}/tce
fi

echo "$dCtype został poprawnie zainstalowany, teraz można uruchomić komputer ponownie.";
