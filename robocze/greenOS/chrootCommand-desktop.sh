#!/bin/bash

PKGS_LIST="network-manager net-tools wireless-tools wpagui openssh-client alsa-utils firefox-esr vim ranger vlc qmmp irssi feh xscreensaver";

dhclient $3;

apt update;
ln -s /etc/dpkg/origins/greenos /etc/dpkg/origins/default;
chmod 755 /usr/share/artwork;

dpkg-reconfigure tzdata;

apt -y install locales;
dpkg-reconfigure locales;
apt -y install keyboard-configuration console-setup;

apt -y install linux-image-amd64 firmware-linux firmware-linux-free firmware-linux-nonfree; 

cd /root;
apt -y install wget lzip xorg;
bash -x os-depends.sh

wget https://github.com/ice-wm/icewm/releases/download/2.4.0/icewm-2.4.0.tar.lz
tar -x --lzip -vpf icewm-2.4.0.tar.lz
cd icewm-2.4.0
bash configure --prefix=/usr
make
make install

cd /root;

mkdir /etc/skel/.icewm;
cp -prvv /usr/share/icewm/* /etc/skel/.icewm;
echo "Theme=\"win95/default.theme\"" > /etc/skel/.icewm/theme;

mkdir /etc/skel/.icewm/themes/win95/taskbar;
cp -v /usr/share/artwork/icewm.xpm /etc/skel/.icewm/themes/win95/taskbar;

echo "prog \"xterm\" xterm xterm -fg orange -bg black" > /etc/skel/.icewm/menu;
echo "prog \"ranger\" xterm xterm -fg orange -bg black -T ranger -e ranger" >> /etc/skel/.icewm/menu;
echo "prog \"irssi\" xterm xterm -fg orange -bg black -T irssi -e irssi" >> /etc/skel/.icewm/menu;
echo "prog \"firefox\" ! x-www-browser" >> /etc/skel/.icewm/menu;
echo "prog \"qmmp\" qmmp qmmp" >> /etc/skel/.icewm/menu;
echo "prog \"VLC\" vlc vlc" >> /etc/skel/.icewm/menu;

echo "TaskBarWorkspacesLimit=\"1\"" >> /etc/skel/.icewm/preferences;

mkdir -p /etc/skel/.config/ranger;
echo "set column_ratios 1,2,3" > /etc/skel/.config/ranger/rc.conf;
echo "set show_hidden true" >> /etc/skel/.config/ranger/rc.conf;

echo "prog \"Terminal\" utilities-terminal xterm -fg orange -bg black" > /etc/skel/.icewm/toolbar;
echo "prog \"Web browser\" ! x-www-browser" >> /etc/skel/.icewm/toolbar;

echo "xscreensaver -no-splash &" > /etc/skel/.xinitrc;
echo "icewmbg --scaled=1 -p -i /usr/share/artwork/greenos_wallpaper.png &" >> /etc/skel/.xinitrc;
echo >> /etc/skel/.xinitrc;
echo "exec icewm-session" >> /etc/skel/.xinitrc;
cp /etc/skel/.xinitrc /etc/skel/.xsession;

passwd root;
adduser $2;

apt -y install $PKGS_LIST;

tasksel install standard;

apt -y install grub2;
grub-install $1;
update-grub

apt-get clean

exit
