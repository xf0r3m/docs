#!/bin/bash

vboxmanage=$(which vboxmanage);
vmname="RHEL9-VM1";
bridged_if="wlp1s0";

#echo $vboxmanage;


$vboxmanage createvm --name $vmname --ostype RedHat_64 --register;

$vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/OS.vdi" --size \
10240 --format VDI --variant Standard;
$vboxmanage storagectl $vmname --name SATA0 --add sata;

$vboxmanage modifyvm $vmname --memory 1024;
$vboxmanage modifyvm $vmname --graphicscontroller vmsvga;
$vboxmanage modifyvm $vmname --nic1 bridged;
$vboxmanage modifyvm $vmname --bridgeadapter1 $bridged_if;

$vboxmanage storageattach $vmname --storagectl SATA0 --port 0 --type hdd --medium \
"$HOME/VirtualBox VMs/${vmname}/OS.vdi";
$vboxmanage storageattach $vmname --storagectl SATA0 --port 1 --type dvddrive \
--medium "$HOME/Pobrane/rhel-baseos-9.0-x86_64-dvd.iso";

