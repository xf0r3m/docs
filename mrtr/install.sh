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

cat >> /etc/dhcpcd.conf <<EOF
interface eth0
static ip_address=192.168.4.1/24
EOF

sudo useradd -m -s /bin/bash pi
echo "pi ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers;

defaultListenAddressLine=$(grep '^#ListenAddress\ 0\.0\.0\.0' /etc/ssh/sshd_config);
newListenAddressLine="ListenAddress 192.168.4.1";
sudo sed -i "s/${defaultListenAddressLine}/${newListenAddressLine}/" /etc/ssh/sshd_config;

