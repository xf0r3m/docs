#!/bin/bash

function help() {
  echo "wlanconn - simple wireless LAN connection via CLI";
  echo "morketsmerke.net @ 2023";
  echo;
  echo "Options:";
  echo -e "\t list - print available WLAN networks list";
  echo;
  echo "Usage: ";
  echo -e "\t$ wlanconn <essid> <psk> #FOR WPA/WPA2";
  echo -e "\t$ wlanconn <essid> s:<key> #FOR WEP";
  echo -e "\t$ wlanconn <essid> #FOR OPEN NETWORKS";
}

if [ "$1" ]; then
  if [ "$1" = "list" ]; then
    /usr/local/bin/wlansum;
  elif [ "$1" = "help" ]; then
    help;
    exit 0;
  else
    essid=$1;
    if [ ! "$2" ]; then
      sudo iwconfig wlan0 $essid;
    elif [ "$2" ] && $(echo $2 | grep -q '^s\:'); then
      sudo iwconfig wlan0 $essid key $2;
    else 
      if ls /etc/wlanconn | grep -q "^$(echo $essid | sed 's/ /_/g')\.conf$"; then
        filename=$(ls /etc/wlanconn | grep "^$(echo $essid | sed 's/ /_/g')\.conf$");
      else
        psk=$2;
        filename="$(echo $essid | sed 's/ /_/g').conf";
        wpa_passphrase $essid $psk > /etc/wlanconn/$filename;
        sudo chown root:wlanconn /etc/wlanconn/$filename;
      fi
      sudo wpa_supplicant -B -D wext -i wlan0 -c /etc/wlanconn/$filename;
    fi
    sudo dhclient wlan0;
 fi
else
  help;
  exit 1;
fi
