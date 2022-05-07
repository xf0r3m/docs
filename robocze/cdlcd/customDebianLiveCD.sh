#!/bin/bash

if [ $(whoami) != root ]; then
	echo "Root privileges are required.";
	exit 1;
fi

LIVE_NAME="greenOS";
DEBIAN_MIRROR="http://ftp.icm.edu.pl/debian";

function createSFS {
  mksquashfs $HOME/${1}/chroot $HOME/${1}/staging/live/filesystem.squashfs -e boot
}

function createISO {
  xorriso -as mkisofs -iso-level 3 -o "${HOME}/${1}/$(echo $1 | tr A-Z a-z).iso" -full-iso9660-filenames -volid "$(echo $1 | tr a-z A-Z)" -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -eltorito-boot isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table --eltorito-catalog isolinux/isolinux.cat -eltorito-alt-boot -e /EFI/boot/efiboot.img -no-emul-boot -isohybrid-gpt-basdat -append_partition 2 0xef ${HOME}/${1}/staging/EFI/boot/efiboot.img "${HOME}/${1}/staging"
}

if [ ! "$1" ]; then  
  apt update;
  apt install -y debootstrap squashfs-tools xorriso isolinux syslinux-efi grub-pc-bin grub-efi-amd64-bin mtools dosfstools

  mkdir $HOME/$LIVE_NAME;

  debootstrap --arch=amd64 --variant=minbase buster $HOME/$LIVE_NAME/chroot $DEBIAN_MIRROR;
  cp chrootCommand.sh $HOME/$LIVE_NAME/chroot;
  chroot $HOME/$LIVE_NAME/chroot bash chrootCommand.sh;

  mkdir -p $HOME/${LIVE_NAME}/{staging/{EFI/boot,boot/grub/x86_64-efi,isolinux,live},tmp}
  createSFS $LIVE_NAME;
  cp $HOME/${LIVE_NAME}/chroot/boot/vmlinuz-* $HOME/${LIVE_NAME}/staging/live/vmlinuz;
  cp $HOME/${LIVE_NAME}/chroot/boot/initrd.img-* $HOME/${LIVE_NAME}/staging/live/initrd;

  ISOLINUX_CFG_PATH=$HOME/${LIVE_NAME}/staging/isolinux/isolinux.cfg;

  echo "UI vesamenu.c32" > $ISOLINUX_CFG_PATH;
  echo >> $ISOLINUX_CFG_PATH;
  echo "MENU TITLE Boot Menu" >> $ISOLINUX_CFG_PATH;
  echo "DEFAULT linux" >> $ISOLINUX_CFG_PATH;
  echo "TIMEOUT 600" >> $ISOLINUX_CFG_PATH;
  echo "MENU RESOLUTION 640 480" >> $ISOLINUX_CFG_PATH;
  echo "MENU COLOR border	30;44 #40ffffff #a0000000 std" >> $ISOLINUX_CFG_PATH;
  echo "MENU COLOR title 1;36;44 #9033ccff #a0000000 std" >> $ISOLINUX_CFG_PATH;
  echo "MENU COLOR sel 7;37;40 #e0ffffff #20ffffff all" >> $ISOLINUX_CFG_PATH;
  echo "MENU COLOR unsel 37;40 #50ffffff #a0000000 std" >> $ISOLINUX_CFG_PATH;
  echo "MENU COLOR help 37;40 #c0ffffff #a0000000 std" >> $ISOLINUX_CFG_PATH;
  echo "MENU COLOR timeout_msg 37;40 #80ffffff #00000000 std" >> $ISOLINUX_CFG_PATH;
  echo "MENU COLOR timeout 1;37;40 #c0ffffff #00000000 std" >> $ISOLINUX_CFG_PATH;
  echo "MENU COLOR msg07 37;40 #90ffffff #a0000000 std" >> $ISOLINUX_CFG_PATH;
  echo "MENU COLOR tabmsg 31;40 #30ffffff #00000000 std" >> $ISOLINUX_CFG_PATH;
  echo >> $ISOLINUX_CFG_PATH;
  echo "LABEL linux" >> $ISOLINUX_CFG_PATH;
  echo "  MENU LABEL ${LIVE_NAME} [BIOS/ISOLINUX]" >> $ISOLINUX_CFG_PATH;
  echo "  MENU DEFAULT" >> $ISOLINUX_CFG_PATH;
  echo "  KERNEL /live/vmlinuz" >> $ISOLINUX_CFG_PATH;
  echo "  APPEND initrd=/live/initrd boot=live" >> $ISOLINUX_CFG_PATH;
  echo >> $ISOLINUX_CFG_PATH;
  echo "LABEL linux" >> $ISOLINUX_CFG_PATH;
  echo "  MENU LABEL ${LIVE_NAME} [BIOS/ISOLINUX] (nomodeset)" >> $ISOLINUX_CFG_PATH;
  echo "  MENU DEFAULT" >> $ISOLINUX_CFG_PATH;
  echo "  KERNEL /live/vmlinuz" >> $ISOLINUX_CFG_PATH;
  echo "  APPEND initrd=/live/initrd boot=live nomodeset" >> $ISOLINUX_CFG_PATH;

  GRUB_CFG_PATH=$HOME/${LIVE_NAME}/staging/boot/grub/grub.cfg;

  echo "search --set=root --file /$(echo $LIVE_NAME | tr a-z A-Z)" > $GRUB_CFG_PATH;
  echo >> $GRUB_CFG_PATH;
  echo 'set default="0"' >> $GRUB_CFG_PATH;
  echo 'set timeout=30' >> $GRUB_CFG_PATH;
  echo "menuentry \"${LIVE_NAME} [EFI/GRUB]\" {" >> $GRUB_CFG_PATH;
  echo "    linux (\$root)/live/vmlinuz boot=live" >> $GRUB_CFG_PATH;
  echo "    initrd (\$root)/live/initrd" >> $GRUB_CFG_PATH;
  echo "}" >> $GRUB_CFG_PATH; echo >> $GRUB_CFG_PATH;
  echo "menuentry \"${LIVE_NAME} [EFI/GRUB] (nomodeset)\" {" >> $GRUB_CFG_PATH;
  echo "    linux (\$root)/live/vmlinuz boot=live nomodeset" >> $GRUB_CFG_PATH;
  echo "    initrd (\$root)/live/initrd" >> $GRUB_CFG_PATH;
  echo "}" >> $GRUB_CFG_PATH;

  GRUB_STD_CFG_PATH=$HOME/${LIVE_NAME}/tmp/grub-standalone.cfg

  echo "search --set=root --file /$(echo $LIVE_NAME | tr a-z A-Z)" >> $GRUB_STD_CFG_PATH;
  echo "set prefix=(\$root)/boot/grub/" >> $GRUB_STD_CFG_PATH;
  echo "configfile /boot/grub/grub.cfg" >> $GRUB_STD_CFG_PATH;

  touch $HOME/${LIVE_NAME}/staging/$(echo $LIVE_NAME | tr a-z A-Z);

  cp /usr/lib/ISOLINUX/isolinux.bin "${HOME}/${LIVE_NAME}/staging/isolinux/";
  cp /usr/lib/syslinux/modules/bios/* "${HOME}/${LIVE_NAME}/staging/isolinux/";

  cp -r /usr/lib/grub/x86_64-efi/* "${HOME}/${LIVE_NAME}/staging/boot/grub/x86_64-efi/";

  grub-mkstandalone --format=x86_64-efi --output=$HOME/${LIVE_NAME}/tmp/bootx64.efi --locales="" --fonts="" "boot/grub/grub.cfg=$HOME/${LIVE_NAME}/tmp/grub-standalone.cfg";

  cd $HOME/${LIVE_NAME}/staging/EFI/boot;
  dd if=/dev/zero of=efiboot.img bs=1M count=20
  mkfs.vfat efiboot.img
  mmd -i efiboot.img efi efi/boot
  mcopy -vi efiboot.img $HOME/${LIVE_NAME}/tmp/bootx64.efi ::efi/boot/

  createISO $LIVE_NAME;

else
  if [ "$1" ] && [ "$1" == "--upgrade" ]; then
    rm $HOME/${LIVE_NAME}/staging/live/filesystem.squashfs;
    rm $HOME/${LIVE_NAME}/$(echo $LIVE_NAME | tr A-Z a-z).iso
    createSFS $LIVE_NAME;
    createISO $LIVE_NAME;
  fi 
fi
