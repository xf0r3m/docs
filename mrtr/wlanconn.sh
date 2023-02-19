#!/bin/bash

function help() {
  echo "wlanconn - simple wireless LAN connection via CLI";
  echo "morketsmerke.net @ 2023";
  echo;
  echo "Options:";
  echo -e "\t list - print available WLAN networks list";
  echo;
  echo "Usage: ";
  echo -e "\t$ wlanconn <essid> [psk] #FOR WPA/WPA2";
  echo -en "\t#If you are trying connect to previous networks, ESSID is everything";
  echo -e " that you need to put";
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
    filename="$(echo $essid | sed 's/ /_/g').conf";
    if [ ! "$2" ]; then
      if ls /etc/wlanconn | grep -q "^${filename}$"; then 
        sudo wpa_supplicant -B -Dwext -iwlan0 -c/etc/wlanconn/$filename;
      else
        sudo iwconfig wlan0 $essid;
      fi
    elif [ "$2" ] && $(echo $2 | grep -q '^s\:'); then
      sudo iwconfig wlan0 $essid key $2;
    else 
      psk=$2;
cat > /etc/wlanconn/$filename <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=PL

network={
        ssid="$essid"
        psk="$psk"
}
EOF
      sudo chown root:wlanconn /etc/wlanconn/$filename;
      sudo wpa_supplicant -B -Dwext -iwlan0 -c/etc/wlanconn/$filename;
    fi
    sudo dhclient wlan0;
 fi
else
  help;
  exit 1;
fi
