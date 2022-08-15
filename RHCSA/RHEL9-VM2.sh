#!/bin/bash

vboxmanage=$(which vboxmanage);
vmname="RHEL9-VM2";
bridged_if="enp1s0";

#echo $vboxmanage;


$vboxmanage createvm --name $vmname --ostype RedHat_64 --register;
$vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/OS.vdi" --size \
10240 --format VDI --variant Standard;

$vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/VDO1.vdi" --size \
10240 --format VDI --variant Standard;
$vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/VDO2.vdi" --size \
10240 --format VDI --variant Standard;

$vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/Stratis.vdi" \
--size 1024 --format VDI --variant Standard;

$vboxmanage storagectl $vmname --name SATA0 --add sata;
$vboxmanage modifyvm $vmname --memory 2048;
$vboxmanage modifyvm $vmname --graphicscontroller vmsvga;
$vboxmanage modifyvm $vmname --nic1 bridged;
$vboxmanage modifyvm $vmname --bridgeadapter1 $bridged_if;

$vboxmanage storageattach $vmname --storagectl SATA0 --port 0 --type dvddrive \
--medium "$HOME/Pobrane/rhel-baseos-9.0-x86_64-dvd.iso";

$vboxmanage storageattach $vmname --storagectl SATA0 --port 1 --type hdd --medium \
"$HOME/VirtualBox VMs/${vmname}/OS.vdi";

i=2;
while [ $i -le 5 ]; do
  $vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/LVM${i}.vdi" --size \
  250 --format VDI --variant Standard;
  $vboxmanage storageattach $vmname --storagectl SATA0 --port $i --type hdd --medium \
  "$HOME/VirtualBox VMs/${vmname}/LVM${i}.vdi";
  i=$((i + 1));
done

$vboxmanage storageattach $vmname --storagectl SATA0 --port 6 --type hdd --medium \
"$HOME/VirtualBox VMs/${vmname}/VDO1.vdi";
$vboxmanage storageattach $vmname --storagectl SATA0 --port 7 --type hdd --medium \
"$HOME/VirtualBox VMs/${vmname}/VDO2.vdi";

$vboxmanage storageattach $vmname --storagectl SATA0 --port 8 --type hdd --medium \
"$HOME/VirtualBox VMs/${vmname}/Stratis.vdi";


