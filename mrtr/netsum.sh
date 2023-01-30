#!/bin/bash

# e - ethernet
# w - wireless
# v - vpn
# a - any

function a_get_ip() {
	if [ "$1" ]; then
		address=$(ip address show $1 | grep 'inet\ ' | awk '{printf $2}');
		shift;
		if [ "$1" ] && [ "$1" = "--nomask" ]; then
			address=$(echo $address | cut -d "/" -f 1);
		fi
	else
		address="N/A";
	fi
	echo $address;
}

function a_get_bcast() {
	if [ "$1" ]; then
		broadcast=$(ip address show $1 | grep 'inet\ ' | awk '{printf $4}');
	else
		broadcast="N/A";
	fi	
	echo $broadcast;
}

function a_get_mac() {
	if [ "$1" ]; then
		mac=$(ip link show $i | tail -1 | awk '{printf $2}');
	else
		mac="N/A";
	fi
	echo $mac;
}

function a_get_gateway(){
	gateway=$(ip route show | grep 'default' | awk '{printf $3}');
	if [ ! "$gateway" ]; then
		gateway="N/A";
	fi
	echo $gateway;
}

function a_get_dns_address() {
	dnsAddress=$(cat /etc/resolv.conf | grep 'nameserver.*[0-9]*\.[0-9]*$' | awk '{printf $2" "}')
	if [ ! "$dnsAddress" ]; then
		dnsAddress="N/A";
	fi
	echo $dnsAddress;
}

function a_is_dhcp_conf(){
	if [ "$1" ]; then
		if ls /var/lib/dhcpcd | grep -q $1; then
			echo "YES";
		else
			echo "NO";
		fi
	else
		echo "N/A"
	fi
	# szczegóły dhcpcd -> dhcpcd -U $iface
}

activeIfList=$(ip a | grep 'state\ UP' | awk '{printf $2" "}' | sed 's/://g');

for iface in $activeIfList; do
	echo "${iface}:";
	if echo $iface | grep -q 'eth'; then
		echo -e "\tType: Ethernet"; # dla testów
		echo -e "\tDHCP: $(a_is_dhcp_conf $iface)";
		echo -e "\tIP: $(a_get_ip $iface)";
		echo -e "\tBroadcast $(a_get_bcast $iface)";
		echo -e "\tMAC: $(a_get_mac $iface)";
	elif echo $iface | grep -q 'wlan'; then
		echo -e "\tType: Wireless"; # dla testów
	else
		continue;
	fi
done
echo;
echo "Gateway: $(a_get_gateway)";
echo "DNS: $(a_get_dns_address)";
echo;
if ip a | grep -q 'tun'; then
	echo "OpenVPN: Connected";
else
	echo "OpenVPN: Not connected";
fi
