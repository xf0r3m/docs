#!/bin/bash

export NEWT_COLORS='
root=green,black
roottext=green,black
title=green,black
window=green,black
border=green,black
textbox=green,black
compactbutton=black,green
button=green,black
actbutton=black,green
listbox=green,black
actlistbox=black,green
sellistbox=green,black
actsellistbox=black,green
textbox=green,black
acttextbox=black,green
emptyscale=green,black
fullscale=black,green
label=green,black
entry=green,black
disentry=black,green
helpline=green,black
';

#Sprawdzenie połączenia z internetem
ping -c1 wp.pl >> /dev/null;
if [ $? -ne 0 ]; then
	whiptail --fb --title "Połączenie z internetem" --backtitle "greenOS Installer" --yesno "Brak połaczenia z internetem. Jest ono niezbędne do instalacji greenOS. Kontynuacja instalacji będzie oznaczać próbę inicjalizacji połaczenia sieciowego.Kontynuować?" 10 80
	if [ $? -eq 0 ]; then
		countIface=$(ip a | grep "^[0-9]*\:" | tail -1 | cut -d ":" -f 1);
		if [ $countIface -gt 2 ]; then
			i=2;
			while [ $i -le $countIface ]; do
				iface=$(ip a | grep "^${i}:" | awk '{printf $2}' | sed 's/://g');
				deviceid=$(dmesg | grep "${iface}:\ renamed" | awk '{printf $4}' | cut -d ":" -f 2-);
				deviceid=$(lspci | grep "$deviceid" | cut -d " " -f 4-);
				echo "${iface} $(echo $devicename | sed 's/ /_/g')" >> iface_list.txt;
				i=$((i + 1));
			done
		else
			iface=$(ip a | grep "^2:" | awk '{printf $2}' | sed 's/://g');
			deviceid=$(dmesg | grep "${iface}:\ renamed" | awk '{printf $4}' | cut -d ":" -f 2-);
			if echo $deviceid | grep -q "Ethernet" ; then
				dhclient $iface >> /dev/null 2>&1;
			else
				ip link set $iface up >> /dev/null 2>&1;
				iwlist $iface scan > scanned_networks.txt;

				array=($(grep -n "Cell" scanned_networks.txt | awk '{printf $1" "}' | sed 's/://g'));
				function formatCell {
					unset security;
					ssid=$(sed -n "$1" scanned_networks.txt | grep "SSID:" | cut -d ":" -f 2 | sed 's/ /\[space\]/g');
					address=$(sed -n "$1" scanned_networks.txt | grep "Address:" | cut -d ":" -f 2- | sed 's/ //g');
					channel=$(sed -n "$1" scanned_networks.txt | grep "Channel:" | cut -d ":" -f 2);
					quality=$(sed -n "$1" scanned_networks.txt | grep -o "Quality\=[0-9]*\/[0-9]*" | cut -d "=" -f 2);
					signal=$(sed -n "$1" scanned_networks.txt | grep -o "Signal\ level\=\-[0-9]\ dBm" | cut -d "=" -f 2 | sed 's/ /_/g');
					if $(sed -n "$1" scanned_networks.txt | grep -q "IE: IEEE 802.11i/WPA2 Version 1") ; then
						if $(sed -n "$1" scanned_networks.txt | grep -q "IE: WPA Version 1") ; then
							security="WPA/WPA2";
						else
							security="WPA2";
						fi
					elif $(sed -n "$1" scanned_networks.txt | grep -q "Encryption key:on") ; then
						if $(sed -n "$1" scanned_networks.txt | grep -q "IE: WPA Version 1") ; then
							security="WPA";
						else
							security="WEP";
						fi
					else
						security="OPEN";
					fi
					echo "${ssid}_${address}_${channel}_${quality}_${signal}_[${security}]"
				}
				
				i=0;
				j=$((i + 1));
				countCells=$(expr ${#array[*]} - 1);
				echo -n > network_list.txt;
				while [ $i -le $countCells ]; do
					if [ $i -eq $countCells ]; then
						sed_command="${array[$i]},\$p";
						echo "$j $(formatCell $sed_command)" >> network_list.txt;
					else
						endOfSection=$(expr ${array[$j]} - 1);
						sed_command="${array[$i]},${endOfSection}p";
						echo "$j $(formatCell $sed_command)" >> network_list.txt;
					fi
					i=$((i + 1));
					j=$((j + 1));
				done

				networkId=$(whiptail --fb --title "Wybierz sieć bezprzewodową" --backtitle "greenOS Installer" --notags --menu "Aby połączyć się z Internetem należy wybrać jedną ze znalezionych w otoczeniu sieci bezprzewodowych." 20 80 10 $(cat network_list.txt) 3>&1 1>&2 2>&3);





#Okno 0: Przywitanie, informacja o wyczyszczeniu dysków, potwierdzenie.
whiptail --fb --title "Witaj!" --backtitle "greenOS Installer"  --defaultno --yesno "Witamy w instalatorze, dystrybucji greenOS, ten program pomoże zainstalować system na Państwa komputerze. Wszystkie dane na dysku przeznaczonym do instalacji zostaną zniszczone. Czy jesteśmy pewni, że chcemy kontynuować?" 10 80 

if [ $? -eq 0 ]; then
	#Utworzenie listy dostępnych w systemie dysków
	fdisk -l | grep "Dysk" | sed 's/ /_/g' > raw_disk_list.txt
	rdcCount=$(cat raw_disk_list.txt | wc -l | awk '{printf $1}');
	i=1;
	while [ $i -le $rdcCount ]; do
		echo "$i $(sed -n "${i}p" raw_disk_list.txt)" >> disk_list.txt
		i=$((i + 1));
	done
	#Okno 1: Wybór dysku:
	disk=$(whiptail --fb --title "Wybór dysku" --backtitle "greenOS Installer" --menu "Proszę o wskaznie dysków na którym ma zostać zainstalowany greenOS" 20 80 10 $(cat disk_list.txt) 3>&1 1>&2 2>&3);
       	#echo "dysk: $disk";	
	rm raw_disk_list.txt
	#rm disk_list.txt
	#Okno 2: Wybór schematu partycjonowania:
	partitioning=$(whiptail --fb --title "Wybór schematu partycjonowania" --backtitle "greenOS Installer" --notags --menu "Proszę wybrać jaki sposób podzielić dyski, dla początkujących zalecany jest podział automatyczny." 20 80 10 1 Automatyczny 2 Ręczny 3>&1 1>&2 2>&3);
	#echo "Partycjonowanie: $partitioning";
	disksize=$(cat disk_list.txt | sed -n "${disk}p" | cut -d "_" -f 3 | sed 's/://');
	disk=$(cat disk_list.txt | sed -n "${disk}p" | cut -d "_" -f 2 | sed 's/://');
	#echo $disk;
	#echo $disksize;
	rm disk_list.txt;
	if [ $partitioning -eq 1 ]; then
		#Automatyczne partycjonowanie dysku za pomocą programu sfdisk
		#Partycjonowanie dysku
		#Pasek 0: Partycjonowanie dysku
		dd if=/dev/zero bs=1M od=$disk count=1 >> /dev/null 2>&1;
		(echo "label: dos" | sfdisk $disk >> /dev/null 2>&1;
			echo 25;
			echo "2048,+$((disksize - 1))G,L,*" | sfdisk $disk >> /dev/null 2>&1;
			echo 50;
			echo ",,E" | sfdisk -a $disk >> /dev/null 2>&1;
			echo 75;
			echo ",,S" | sfdisk -a $disk >> /dev/null 2>&1;
			echo 100;) | whiptail --fb --title "Partycjonowanie dysków" --backtitle "greeenOS Installer" --gauge "Przygotowanie dysku do instalacji greenOS" 10 80 0;
		#Okno 4: Podsumowanie partycjonowania dysku.	
		whiptail --fb --title "Partycjonowanie dysków" --backtitle "greenOS Installer" --msgbox "Automatycznie dysk został spartycjonowany w następujący sposób: $(fdisk -l $disk)" 25 80;
		#Tworzenie systemów plików na utworzonych partycjach
		#Pasek 1: Formatowanie partycji.
		(mkfs.ext4 -F ${disk}1 >> /dev/null 2>&1;
			echo "50";
			mkswap -F ${disk}5 >> /dev/null 2>&1;
			echo "100") | whiptail --fb --title "Tworzenie systemów plików" --backtitle "greenOS Installer" --gauge "Przygotowanie dysku do instalacji greenOS" 10 80 0;
		#Montowanie utworzonych systemów plików
		#Pasek 2: Montowanie dysków.
		(mount ${disk}1 /mnt >> /dev/null 2>&1;
			echo 50;
			swapon ${disk}5 >> /dev/null 2>&1;
			echo 100;) | whiptail --ft --title "Montowanie systemów plików" --backtitle "greenOS Installer" --gauge "Montowanie systemów plików" 10 80 0;	
	else
		fdisk $disk;
	fi
	#Okno 5: Wybór trybu instalacji
	installation=$(whiptail --fb --title "Tryb instalacji" --backtitle "greenOS Installer" --menu "GreenOS można zainstalować na trzy sposoby: 1 - desktop - zawiera niezbędne lekkie oprogramowanie do wykorzystania tego systemu na komputerze biurkowym do codziennej pracy; 2 - server - instalacja bez środowiska graficznego zawiera jedynie edytora oraz serwer SSH; 3 - hacker - najczystsza instalacja nie zawiera żadnych pakietów poza niezbędnymi do działania systemu." 30 80 10 1 desktop 2 server 3 hacker 3>&1 1>&2 2>&3);

	if [ $installation -eq 1 ]; then mode="desktop";
	elif [ $installation -eq 2 ]; then mode="server";
	else mode="hacker"; fi

	echo "Mode: $mode";

	unamea=$(uname -m)
	if [ "$unamea" = "x86_64" ]; then arch="amd64";
	else arch="i386";
	fi

	echo "Arch: $arch";

	cd /mnt;
	#Pasek 3: Instalacja systemu.
	rootfsUrl="http://192.168.8.183/greenOS/rootfs/${arch}/${mode}/rootfs_${unamea}_${mode}.tgz";
	#Pobranie rootfs z serwera;
	(wget -q $rootfsUrl;
		echo 33;
		tar -xzf rootfs_${unamea}_${mode}.tgz;
		echo 66;
		rm rootfs_${unamea}_${mode}.tgz;
		echo 100;) | whiptail --fb --title "Instalacja systemu" --backtitle "greenOS Installer" --gauge "Proszę czekać, trwa instalacja systemu. Może ona potrwać na kilkadziesiąt minut w zależności od szybkości łącza oraz mocy obliczeniowej komputera. Pasek postępu nie oddaje rzeczywistych działań w systemie" 10 80 0;
	#Generowanie tablicy /etc/fstab;
	if [ $partitioning -eq 1 ]; then
		rootUUID=$(blkid | grep "${disk}1" | cut -d " " -f 2);
		swapUUID=$(blkid | grep "${disk}5" | cut -d " " -f 2);

		echo -e "$rootUUID\t/\text4\tdefaults\t0\t1" > /mnt/etc/fstab;
		echo -e "$swapUUID\tnone\tswap\tsw\t0\t0" >> /mnt/etc/fstab;
	else
		blkid > /mnt/etc/fstab;
		vim /mnt/etc/fstab;
	fi
	#Okno 6: Ustawienie nazwy komputera
	#Pobranie oraz ustawienie nazwy komputera
	computername=$(whiptail --fb --title "Nazwa komputera" --backtitle "greenOS Installer" --inputbox "Proszę podać nazwę hosta dla komputera z greenOS:" 15 80 3>&1 1>&2 2>&3);
	echo "$computername" > /mnt/etc/hostname;
	sed -i "s/greenOS/${computername}/" /mnt/etc/hosts;
	#Okno 7: Pobranie hasła roota.
	rootpassword=$(whiptail --fb --title "Hasło użytkownika root" --backtitle "greenOS Installer" --passwordbox "Proszę podać hasło użytkownika root:" 10 80 3>&1 1>&2 2>&3);
	#Okno 8: Pobranie nazwy nowego użytkownika
	username=$(whiptail --fb --title "Nazwa nowego użytkownika" --backtitle "greenOS Installer" --inputbox "Proszę podać nazwę nowego użytkownika. Praca na koncie zwykłego użytkownika jest bezpieczniejsza do pracy na koncie root" 10 80 3>&1 1>&2 2>&3);
	#Okno 9: Pobranie hasła nowego użytkowniaka
	userpasswd=$(whiptail --fb --title "Hasło nowego użytkownika" --backtitle "greenOS Installer" --passwordbox "Prosze podać hasło nowego uzytkownika: " 10 80 3>&1 1>&2 2>&3);
	#Utworznie skryptu dla chroot
	echo "#!/bin/bash" > chrootCommand.sh;
	echo "" >> chrootCommand.sh;
	echo "chpasswd <<<\"root:${rootpassword}\"" >> chrootCommand.sh;
        echo "adduser --quiet --gecos \"\" --disabled-password $username ">> chrootCommand.sh;
	echo "chpasswd <<< \"${username}:$userpasswd\"" >> chrootCommand.sh;
	echo "grub-install $disk" >> chrootCommand.sh;
	echo "update-grub" >> chrootCommand.sh;
	echo "exit" >> chrootCommand.sh;
	#Podmontowanie niezbędnych katalogów
	for i in /dev /dev/pts /proc /sys /run; do mount -B $i /mnt$i; done
	#Wykonanie skryptu chroot - ustawienie użytkowników, haseł, instalacja grub-a.
	chroot /mnt /bin/bash chrootCommand.sh;
	for i in /dev /dev/pts /proc /sys /run; do umount -R /mnt$i; done
	cd /
	umount -R /mnt
	#Okno 10: Zakończenie instalacji - Reboot;
	whiptail --fb --title "Zakończenie instalacji" --backtitle "greenOS Installer" --msgbox "Instalacja zakończona, proszę wybrać OK, aby zrestartować system." 10 80
	#reboot;	


else
	exit 1;
fi
