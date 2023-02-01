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

function is_vpn_connected() {
  if ip a | grep -q 'tun[0-9]*'; then return 0; else return 1; fi
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
        'w_channel') if is_wlan $interface; then
                          frequency=$(sudo iwconfig wlan0 | grep -o 'Frequency:2\.[0-9]*\ GHz' | cut -d ":" -f 2 | awk '{printf $1}');
                          case $frequency in
                            '2.412') value='1';;
                            '2.417') value='2';;
                            '2.422') value='3';;
                            '2.427') value='4';;
                            '2.432') value='5';;
                            '2.437') value='6';;
                            '2.442') value='7';;
                            '2.447') value='8';;
                            '2.452') value='9';;
                            '2.457') value='10';;
                            '2.462') value='11';;
                            '2.467') value='12';;
                            '2.472') value='13';;
                            '2.484') value='14';;
                          esac
                          value="${value} (${frequency} GHz)";
                      fi;;
        'v_state') if ip a | grep -q 'tun[0-9]*'; then
                      value='Connected';
                    else
                      value='Not connected';
                    fi;;
        'v_node') if is_vpn_connected; then
                      nodesFile="/tmp/nodes.txt";
                      if [ ! -f $nodesFile ]; then
                          wget https://vpn.morketsmerke.net/nodes.txt -O $nodesFile;
                      fi
                      openVPNConfigFile="/etc/openvpn/client/client.conf";
                      vpnNode=$(grep -o 'remote\ [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' $openVPNConfigFile | awk '{printf $2}');
                      value=$(grep "$vpnNode" $nodesFile | awk '{printf $2}');
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

function output() {
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
      echo -e "\tChannel: $(api $iface 'w_channel')";
      elementary_info $iface;
    else
		  continue;
	  fi
  done
  echo;
  if ! echo $activeIfList | grep -q 'wlan[0-9]*'; then
    iface=$(ip address | grep -o 'wlan[0-9]*');
    if [ "$iface" ]; then
      numberOfNetworks=$(iwlist $iface scan | grep -o 'Cell\ [0-9]*' | tail -1 | awk '{printf $2}')
      echo "${iface}:";
      echo -e "\tDiscovered wireless networks: ${numberOfNetworks}";
      echo;
    fi
  fi
  echo "Gateway: $(api 'eth0' 'a_get_gateway')";
  echo "DNS: $(api 'eth0' 'a_get_dns')";
  echo;
  echo "OpenVPN:";
  echo -e "\tVPN state: $(api 'eth0' 'v_state')";
  echo -e "\tVPN node: $(api 'eth0' 'v_node')";
}

clear > /dev/tty0;
output > /dev/tty0;
