#!/bin/bash

chroot_dir=$1;

#${chroot_dir}/etc/issue:
echo "greenOS GNU/Linux 1 \n \l" > ${chroot_dir}/etc/issue;

#${chroot_dir}/etc/issue.net:
echo "greenOS GNU/Linux 1" > ${chroot_dir}/etc/issue.net;

rm ${chroot_dir}/etc/dpkg/origins/default;
#${chroot_dir}/etc/dpkg/origins/greenos:
echo "Vendor: greenOS" > ${chroot_dir}/etc/dpkg/origins/greenos;
echo "Vendor-URL: https://morketsmerke.net/site/greenos" >> ${chroot_dir}/etc/dpkg/origins/greenos;
echo "Bugs: debbugs://bugs.morketsmerke.net" >> ${chroot_dir}/etc/dpkg/origins/greenos;
ln -s ${chroot_dir}/etc/dpkg/origins/greenos ${chroot_dir}/etc/dpkg/origins/default;

#${chroot_dir}/usr/lib/os-release:
echo 'PRETTY_NAME="greenOS GNU/Linux 1 (first)"' > ${chroot_dir}/usr/lib/os-release;
echo 'NAME="greenOS GNU/Linux"' >> ${chroot_dir}/usr/lib/os-release;
echo 'VERSION_ID="1"' >> ${chroot_dir}/usr/lib/os-release;
echo 'VERSION="1 (first)"' >> ${chroot_dir}/usr/lib/os-release;
echo 'VERSION_CODENAME=first"' >> ${chroot_dir}/usr/lib/os-release;
echo 'ID=greenos' >> ${chroot_dir}/usr/lib/os-release;
echo 'HOME_URL="https://morketsmerke.net/site/greenos"' >> ${chroot_dir}/usr/lib/or-release;
echo 'SUPPORT_URL="https://morketsmerke.net/site/greenos/support"' >> ${chroot_dir}/usr/lib/os-release;
echo 'BUG_REPORT_URL="https://bugs.morketsmerke.net"' >> ${chroot_dir}/usr/lib/os-release;

#${chroot_dir}/usr/share/base-files/motd:
sed -i 's/Debian/greenOS/g' ${chroot_dir}/usr/share/base-files/motd;

#${chroot_dir}/etc/motd:
sed -i 's/Debian/greenOS/g' ${chroot_dir}/etc/motd;
