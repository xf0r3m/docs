#!/bin/bash

# e - ethernet
# w - wireless
# v - vpn
# a - any

function is_eth() {
  if echo $1 | grep -q 'eth[0-9]*'; then return 0; else return 1; fi
}

function is_wlan() {
  if echo $1 | grep -q 'wlan[0-9]*'; then return 0; else return 1; fi
}
  
function api() {
	if [ "$1" ]; then
		if echo $1 | grep -Eq '(eth[0-9]*|wlan[0-9]*)'; then
			interface=$1;
      function=$2;
			case $function in
				'a_get_ip') value=$(ip address show $interface | grep 'inet\ ' | awk '{printf $2}');;
        'a_get_bcast') value=$(ip address show $interface | grep 'inet\ ' | awk '{printf $4}');;
        'a_get_mac') value=$(ip link show $interface | tail -1 | awk '{printf $2}');;
        'a_get_gateway') value=$(ip route show | grep 'default' | awk '{printf $3" "}');;
        'a_get_dns') value=$(cat /etc/resolv.conf | grep 'nameserver.*[0-9]*\.[0-9]*$' | awk '{printf $2" "}');;
        'a_is_dhcp_conf') if ls -la /var/lib/dhcpcd | grep -q $interface; then
                            value="YES";
                          else
                            value="NO";
                          fi;;
        'a_get_dhcpd_ip') dhcpConfFlag=$(api $interface 'a_is_dhcp_conf');
                          if [ "$dhcpConfFlag" = "YES" ]; then
                            value=$(dhcpcd -U $interface 2> /dev/null | grep 'server_identifier' | cut -d "=" -f 2 | sed "s/'//g");
                          fi;;
        'e_get_link_speed') if is_eth $interface; then
                              value=$(ethtool $interface 2>/dev/null | grep 'Speed:\ ' | awk '{printf $2}');
                            fi;;
        'e_get_duplex') if is_eth $interface; then
                          value=$(ethtool $interface 2>/dev/null | grep 'Duplex:\ ' | awk '{printf $2}');
                        fi;;
        'e_link_detect') if is_eth $interface; then
                          value=$(ethtool $interface 2>/dev/null | grep 'detected:\ ' | awk '{printf $3}' | tr [a-z] [A-Z]);
                         fi;;
        'w_essid') if is_wlan $interface; then
                          value=$(iwconfig $interface | grep -o 'ESSID:.*$' | cut -d ":" -f 2);
                    fi;;
        'w_bitrate') if is_wlan $interface; then
                          value=$(iwconfig $interface | grep -o 'Bit\ Rate=[0-9]*\ Mb\/s' | cut -d "=" -f 2);
                      fi;;
        'w_signal') if is_wlan $interface; then
                          value=$(iwconfig $interface | grep -o 'Signal\ level=\-[0-9]*\ dBm' | cut -d "=" -f 2);
                      fi;;
			esac
      if [ ! "$value" ]; then value="N/A"; fi
      echo $value; 
		else
			echo "Error: This interface isn't fit for Raspberry Pi OS Scheme";
			return 1;
		fi
	else
		echo "Error: interface is required";
		return 1;
	fi	
}

function elementary_info() {
    echo -e "\tMAC: $(api $1 'a_get_mac')";
    echo;
		echo -e "\tIP: $(api $1 'a_get_ip')";
		echo -e "\tBroadcast: $(api $1 'a_get_bcast')";
    echo;
    echo -e "\tDHCP: $(api $1 'a_is_dhcp_conf')";
    echo -e "\tDHCP Server: $(api $1 'a_get_dhcpd_ip')";
}

activeIfList=$(ip a | grep 'state\ UP' | awk '{printf $2" "}' | sed 's/://g');

for iface in $activeIfList; do
	echo "${iface}:";
	if echo $iface | grep -q 'eth'; then
		echo -e "\tType: Ethernet"; # dla testów
    echo -e "\tLink detected: $(api $iface 'e_link_detect')";
    echo -e "\tLink speed: $(api $iface 'e_get_link_speed')";
    elementary_info $iface;
	elif echo $iface | grep -q 'wlan'; then
		echo -e "\tType: Wireless"; # dla testów
    echo -e "\tSSID: $(api $iface 'w_essid')";
    echo -e "\tBit rate: $(api $iface 'w_bitrate')";
    echo -e "\tSignal: $(api $iface 'w_signal')";
    elementary_info $iface;
  else
		continue;
	fi
done
echo;
echo "Gateway: $(api 'eth0' 'a_get_gateway')";
echo "DNS: $(api 'eth0' 'a_get_dns')";
echo;
if ip a | grep -q 'tun'; then
	echo "OpenVPN: Connected";
else
	echo "OpenVPN: Not connected";
fi
