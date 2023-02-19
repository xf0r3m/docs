#!/bin/bash

# WLAN as WAN
# ETH as LAN (192.168.4.1/24)
# dnsmasq (as dhcp server and dns cache)
# hostapd (just installed)
# SSH (opened only on ETH)
# iptables (for drop policy and NAT)
# add pi user with sudo without password

sudo apt update;
sudo apt upgrade;

sudo apt install dnsmasq hostapd iptables netfilter-persistent iptables-persistent;

echo "interface eth0" | sudo tee -a /etc/dhcpcd.conf;
echo -e "\tstatic ip_address=192.168.4.1/24" | sudo tee -a /etc/dhcpcd.conf;
echo | sudo tee -a /etc/dhcpcd.conf;
echo "nohook wpa_supplicant" | sudo tee -a /etc/dhcpcd.conf;
sudo systemctl stop wpa_supplicant.service;
sudo systemctl disable wpa_suplicant.service;

sudo useradd -m -s /bin/bash pi
echo "pi ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers;

sudo mkdir /etc/wlanconn;
sudo groupadd wlanconn;
sudo chown root:wlanconn /etc/wlanconn;
sudo chmod 775 /etc/wlanconn;

defaultListenAddressLine=$(grep '^#ListenAddress\ 0\.0\.0\.0' /etc/ssh/sshd_config);
newListenAddressLine="ListenAddress 192.168.4.1";
sudo sed -i "s/${defaultListenAddressLine}/${newListenAddressLine}/" /etc/ssh/sshd_config;

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.d/mrtr.conf;

sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE;
sudo iptables -A INPUT -i wlan0 -p udp -j DROP;
sudo iptables -A INPUT -i wlan0 -p tcp --syn -j DROP;
sudo iptables -A INPUT -p udp --sport 53 -j ACCEPT;
sudo iptables -A INPUT -p udp --sport 67 -j ACCEPT;
sudo iptables -A INPUT -p udp --sport 17003 -j ACCEPT;

sudo netfilter-persistent save;
