#!/bin/bash

vboxmanage=$(which vboxmanage);
vmname="RHEL9-VM2";
bridged_if="wlp1s0";

#echo $vboxmanage;


$vboxmanage createvm --name $vmname --ostype RedHat_64 --register;
$vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/OS.vdi" --size \
1024000 --format VDI --variant Standard;

$vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/VDO.vdi" --size \
4096 --format VDI --variant Standard;
$vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/Stratis.vdi" \
--size 1024 --format VDI --variant Standard;

$vboxmanage storagectl $vmname --name SATA0 --add sata;
$vboxmanage modifyvm $vmname --memory 2048;
$vboxmanage modifyvm $vmname --graphicscontroller vmsvga;
$vboxmanage modifyvm $vmname --nic1 bridged;
$vboxmanage modifyvm $vmname --bridgeadapter1 $bridged_if;

$vboxmanage storageattach $vmname --storagectl SATA0 --port 0 --type hdd --medium \
"$HOME/VirtualBox VMs/${vmname}/OS.vdi";

i=1;
while [ $i -le 4 ]; do
  $vboxmanage createhd --filename "$HOME/VirtualBox VMs/${vmname}/LVM${i}.vdi" --size \
  250 --format VDI --variant Standard;
  $vboxmanage storageattach $vmname --storagectl SATA0 --port $i --type hdd --medium \
  "$HOME/VirtualBox VMs/${vmname}/LVM${i}.vdi";
  i=$((i + 1));
done

$vboxmanage storageattach $vmname --storagectl SATA0 --port 5 --type hdd --medium \
"$HOME/VirtualBox VMs/${vmname}/VDO.vdi";
$vboxmanage storageattach $vmname --storagectl SATA0 --port 6 --type hdd --medium \
"$HOME/VirtualBox VMs/${vmname}/Stratis.vdi";

$vboxmanage storageattach $vmname --storagectl SATA0 --port 7 --type dvddrive \
--medium "$HOME/Pobrane/rhel-baseos-9.0-x86_64-dvd.iso";

