#!/bin/bash

iface=$1;
ip link set $iface up >> /dev/null 2>&1;
iwlist $iface scan > scanned_networks.txt;

array=($(grep -n "Cell" scanned_networks.txt | awk '{printf $1" "}' | sed 's/://g'));

echo ${array[@]};
#echo ${array[0]};

function formatCell {
    unset security;
    ssid=$(sed -n "$1" scanned_networks.txt | grep "SSID:" | cut -d ":" -f 2 | sed 's/ /\[space\]/g');
    address=$(sed -n "$1" scanned_networks.txt | grep "Address:" | cut -d ":" -f 2- | sed 's/ //g');
    channel=$(sed -n "$1" scanned_networks.txt | grep "Channel:" | cut -d ":" -f 2);
    quality=$(sed -n "$1" scanned_networks.txt | grep -o "Quality\=[0-9]*\/[0-9]*" | cut -d "=" -f 2);
    signal=$(sed -n "$1" scanned_networks.txt | grep -o "Signal\ level\=\-[0-9]*\ dBm" | cut -d "=" -f 2 | sed 's/ /_/g');
    if $(sed -n "$1" scanned_networks.txt | grep -q "IE: IEEE 802.11i/WPA2 Version 1") ; then
      if $(sed -n "$1" scanned_networks.txt | grep -q "IE: WPA Version 1") ;  then
        security="WPA/WPA2";
      else
        security="WPA2";
      fi
    elif $(sed -n "$1" scanned_networks.txt | grep -q "Encryption key:on") ; then
      if $(sed -n "$1" scanned_networks.txt | grep -q "IE: WPA Version 1"); then
        security="WPA";
      else 
        security="WEP";
      fi
    else
      security="OPEN";
    fi
    echo -e "${ssid}_${address}_${channel}_${quality}_${signal}_[${security}]";

}

i=0;
j=$((i + 1));
countCells=$(expr ${#array[*]} - 1);
echo -n > networks_list.txt;
while [ $i -le $countCells ]; do
  if [ $i -eq $countCells ]; then
    sed_command="${array[$i]},\$p";
    echo "$j $(formatCell $sed_command)" >> networks_list.txt
  else
    endOfSection=$(expr ${array[$j]} - 1);
    sed_command="${array[$i]},${endOfSection}p"
    echo "$j $(formatCell $sed_command)" >> networks_list.txt;
    #sed -n "${array[$i]},${endOfSection}p" scanned_networks.txt;
    #echo "--------------------------------------------------------------------";
  fi
  i=$((i + 1));
  j=$((j + 1));
done

networkId=$(whiptail --fb --title "Wybierz sieci bezprzewodową" --backtitle "wificonnection2.sh" --notags --menu "Aby połączyć się z Internetem należy wybrać jedną ze znalezionych w otoczeniu sieci bezprzewodowych" 20 80 10 $(cat networks_list.txt) 3>&1 1>&2 2>&3);

security=$(cat networks_list.txt | sed -n "${networkId}p" | grep -o "\[[A-Z]*.*\]");
ssid=$(cat networks_list.txt | sed -n "${networkId}p" | grep -o "\".*\"" | sed 's/"//g');

if $(echo $ssid | grep -q "\[space\]") ; then
  ssid=$(echo $ssid | sed 's/\[space\]/ /g');
fi

if $(echo $security | grep -q "WPA") ; then 
  psk=$(whiptail --fb --title "Klucz sieci WPA" --backtitle "wificonnection2.sh" --passwordbox "Klucz PSK:" 10 80 3>&1 1>&2 2>&3);
  wpa_passphrase "$ssid" $psk > wpa_supplicant.conf;
  wpa_supplicant -B -D wext -i $iface -c wpa_supplicant.conf;
  dhclient $iface;
elif $(echo $security | grep -q "WEP") ; then
 enckey=$(whiptail --fb --title "Klucz sieci WEP" --backtitle "wificonnection2.sh" --passwordbox "Klucz szyfrowania:" 10 80 3>&1 1>&2 2>&3);
 if $(echo $enckey | grep -q "[^1234567890ABCDEF]") ; then
  iwconfig $iface essid $ssid enc s:${enckey};
 else 
  iwconfig $iface essid $ssid enc $enckey;
 fi
 dhclient $iface 
else
  iwconfig $iface essid $ssid;
fi
 
ping -c1 wp.pl >> /dev/null 2>&1;
if [ $? -eq 0 ]; then
  whiptail --fb --title "Połączenie" --backtitle "wificonnection2.sh" --msgbox "Połączenie powiodło sie" 10 80;
else
  whiptail --fb --title "Połączenie" --backtitle "wificonnection2.sh" --msgbox "Połączenie nie powiodło się. Sprawdż czy wybrałeś sieć, do której masz dostęp oraz czy wpisane klucze są prawidłowe, o ile połączenie ich wymaga." 10 80;
fi
  
