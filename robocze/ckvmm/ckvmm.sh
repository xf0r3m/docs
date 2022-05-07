#!/bin/bash

host kvm.morketsmerke.net > /dev/null 2>&1;

if [ $? -eq 0 ]; then host=kvm.morketsmerke.net;
else host=morketsmerke.net; fi

server=$(whiptail --fb --title "Połączenie SSH z maszynami KVM" --backtitle CKVMM --notags --menu "Aby połączyć się z maszyną należy wybrać ją z listy:" 20 80 10 1 testhost-vm 2 greenOSRootFSBuilderAmd64 3 greenOSRootFSBuilderI386 4 greenOSLiveBuilderI386 5 greenOSLiveBuilderAmd64 3>&1 1>&2 2>&3);

case $server in 
 1) ssh -o ProxyCommand="openssl s_client -quiet -connect $host:2222 -servername server1" testhost-vm;;
 2) ssh -o ProxyCommand="openssl s_client -quiet -connect $host:2222 -servername server2" greenosrootfsbuilderamd64;;
 3) ssh -o ProxyCommand="openssl s_client -quiet -connect $host:2222 -servername server3" greenosrootfsbuilderi386;;
 4) ssh -o ProxyCommand="openssl s_client -quiet -connect $host:2222 -servername server4" greenoslivebuilderi386;;
 5) ssh -o ProxyCommand="openssl s_client -quiet -connect $host:2222 -servername server5" greenoslivebuilderamd64;;
esac  

