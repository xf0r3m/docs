#!/bin/bash

LIVE_NAME="greenOS";
PKGS_LIST="network-manager net-tools iproute2 wireless-tools wget openssh-client alsa-utils firefox-esr icewm xserver-xorg-core xserver-xorg xinit xterm vim iputils-ping man man-db texinfo less irssi ranger vlc qmmp feh dosfstools bc sudo figlet isc-dhcp-client fdisk alsa-firmware-loaders whiptail locales keyboard-configuration console-setup";

#Pliki do przesłania:
# greenos_wallpaper.png - tapeta pulpitu
# icewm.xpm - logo przycisku "Start"
# terminal.png - ikona aplikacji terminalowych w menu oraz terminala w toolbarze
# .icewm/menu - plik menu
# .icewm/theme - plik domyślnego tematu
# .icewm/themes/win95/taskbar - miejsce do wrzucenia pliku z logiem "start"
# .icewm/preferences - plik ustawień icewm
# .icewm/toolbar - plik paska zadań ze skrótami aplikacji
# .config/ranger/rc.conf - plik RC rangera
# .vimrc - plik RC Vim
# XTerm - plik RC xterm
# .xinitrc/.xsession - pliki RC dla xinit


#WALLPAPER_URL="http://192.168.8.166:8080/Dokumenty/greenos.png";
mkdir /root/greenOS/chroot/usr/share/artwork
#Przesłać obraz przycisku start, tapetę na maszynę ikonę terminala, następnie przenieść
#te pliki do powyższego katalogu.

apt update;
apt install -y --no-install-recommends linux-image-amd64 live-boot systemd-sysv;

apt install -y wget

apt install -y $PKGS_LIST;

mkdir ${HOME}/.icewm;
cp -prvv /usr/share/icewm/* ${HOME}/.icewm;
echo "Theme=\"win95/default.theme\"" > ${HOME}/.icewm/theme;
echo "prog \"Terminal\" utilities-terminal xterm -fg orange -bg black" > ${HOME}/.icewm/toolbar;
echo "prog \"Web browser\" ! x-www-browser" >> ${HOME}/.icewm/toolbar;

mkdir ${HOME}/.${LIVE_NAME};
wget $WALLPAPER_URL -O ${HOME}/.${LIVE_NAME}/${LIVE_NAME}_wallpaper;

echo "icewmbg --scaled=1 -p -i .${LIVE_NAME}/${LIVE_NAME}_wallpaper &" > ${HOME}/.xinitrc;
echo >> ${HOME}/.xinitrc;
echo "exec icewm-session" >> ${HOME}/.xinitrc;
cp ${HOME}/.xinitrc ${HOME}/.xession;

passwd root

exit
