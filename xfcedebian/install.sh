#!/bin/bash

set -e
source /etc/os-release;

# Pakiet conky jest pakietem wirtualnym zapewnianym przez:
#  conky-std 1.19.5-1
#  conky-cli 1.19.5-1
#  conky-all 1.19.5-1
#Należy jednoznacznie wybrać jeden z nich do instalacji.

if [ "$NAME" = "Arch Linux" ]; then
  sudo pacman -Syu ranger git mpv yt-dlp vlc qutebrowser tmux keepassxc conky gvim claws-mail;
elif [ "$NAME" = "Alpine Linux" ]; then
  sudo apk add ranger git mpv yt-dlp vlc qutebrowser tmux keepassxc conky gvim claws-mail xfce4-whiskermenu-plugin xfce4-notifyd pulseaudio xfce4-pulseaudio-plugin;
else
  sudo apt install -y ranger git mpv vlc qutebrowser tmux keepassxc conky-all vim-gtk3 claws-mail curl;
  ytdlpVer=$(curl https://github.com/yt-dlp/yt-dlp/releases.atom 2>/dev/null | grep '<title>.*</title>$' | sed -n '2p' | sed 's/\ /\n/g' | tail -1 | sed 's,</title>,,');
  curl -L https://github.com/yt-dlp/yt-dlp/releases/download/${ytdlpVer}/yt-dlp -O
fi

if [ "$1" ] && [ "$1" = "--immudex" ]; then

	mkdir /etc/skel/.config;
	cp -rvv xfce4 /etc/skel/.config;
	cp -vv xfce4/xfconf/xfce-perchannel-xml/xfce4-panel-immudex.xml /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml;
  rm /etc/skel/.config/xfce4/panel/launcher-5/17578428061.desktop;
	cp -vv mimeapps.list /etc/skel/.config;
	
	mkdir /etc/skel/.config/autostart;
	cp conky.desktop /etc/skel/.config/autostart;

	cp vimrc /etc/skel/.vimrc;
	cp conkyrc-immudex /etc/skel/.conkyrc;
	if [ -f /etc/skel/.face ]; then rm /etc/skel/.face; fi
	ln -s /usr/share/images/desktop-base/immudex_xfce_greeter_logo.png /etc/skel/.face;
	cp icons/* /usr/share/icons;
	ln -s /usr/share/icons/changes-prevent.png /usr/share/icons/padlock-icon.png;
else
	if [ ! -d /home/${USER}/.config ]; then
		mkdir /home/${USER}/.config;
	fi

	cp -rvv xfce4 /home/${USER}/.config;
  rm /home/${USER}/.config/xfce4/panel/launcher-5/16844254192.desktop;

  if [ "$NAME" = "Ubuntu" ]; then
    sed -i 's,debian-logo,ubuntu-logo,' /home/${USER}/.config/xfce4/panel/whiskermenu-1.rc;
  elif [ "$NAME" = "Arch Linux" ]; then
    sed -i 's,debian-logo,archlinux-logo,' /home/${USER}/.config/xfce4/panel/whiskermenu-1.rc;
  elif [ "$NAME" = "Alpine Linux" ]; then
    sed -i 's,debian-logo,alpine-logo,' /home/${USER}/.config/xfce4/panel/whiskermenu-1.rc;
  fi

  if [ "$NAME" = "Alpine Linux" ]; then
    sed -i 's/Adwaita-dark/adw-gtk3-dark/' /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml;
    IconThemeName=$(grep 'IconThemeName' /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml)
    IconThemeNameNew='    <property name="IconThemeName" type="string" value="adwaita-xfce"/>'
    sed -i "s,${IconThemeName},${IconThemeNameNew}," /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml;
    favKeepass='<value type="string" value="org.keepassxc.KeePassXC.desktop"/>';
    favMPV='<value type="string" value="mpv.desktop"/>';
    favQtBrow='<value type="string" value="org.qutebrowser.qutebrowser.desktop"/>';
    favCMail='<value type="string" value="claws-mail.desktop"/>';
    sed -i "90i ${favKeepass}" /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml;
    sed -i "91i ${favCMail}" /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml;
    sed -i "92i ${favQtBrow}" /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml;
  sed -i "93i ${favMPV}" /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml;

  fi
  
  favOld=$(grep 'favorites=' xfce4/panel/whiskermenu-1.rc);
  favNew="${favOld},org.qutebrowser.qutebrowser.desktop,org.keepassxc.KeePassXC.desktop,claws-mail.desktop";
  sed -i "s/${favOld}/${favNew}/" /home/${USER}/.config/xfce4/panel/whiskermenu-1.rc

	cp -vv mimeapps.list /home/${USER}/.config;
	
	if [ ! -d /home/${USER}/.config/autostart ]; then
		mkdir /home/${USER}/.config/autostart;
	fi
	cp conky.desktop /home/${USER}/.config/autostart;

	cp vimrc /home/${USER}/.vimrc;
	cp conkyrc /home/${USER}/.conkyrc;

	if [ -f /home/${USER}/.face ]; then rm /home/${USER}/.face; fi
  if [ "$NAME" = "Ubuntu" ]; then
    ln -s /usr/share/icons/LoginIcons/apps/64/computer.svg /home/${USER}/.face;
    ln -s /home/${USER}/.face /home/${USER}/.face.icon;
  elif [ "$NAME" = "Debian" ]; then
	  ln -s  /usr/share/icons/vendor/256x256/emblems/emblem-vendor.png /home/${USER}/.face;
  elif [ "$NAME" = "Arch Linux" ]; then
    ln -s /usr/share/pixmaps/archlinux-logo.png /home/${USER}/.face;
    ln -s /home/${USER}/.face /home/${USER}/.face.icon;
  elif [ "$NAME" = "Alpine Linux" ]; then
    ln -s /usr/share/pixmaps/alpine-logo.svg /home/${USER}/.face;
    ln -s /usr/${USER}/.face /home/${USER}/.face.icon;
  fi
fi

sudo cp -vv mimeinfo.cache /usr/share/applications;
sudo mkdir -p /usr/share/fonts/truetype/meslo;
sudo tar -xzvf fonts.tgz -C /usr/share/fonts/truetype/meslo;

if [ ! "$NAME" = "Arch Linux" ]; then
  sudo rm -rf /etc/lightdm;
  sudo cp -rvv lightdm /etc;
  if [ "$NAME" = "Alpine Linux" ]; then
    sudo sed -i 's,Adwaita-dark,adw-gtk3-dark,' /etc/lightdm/lightdm-gtk-greeter.conf;
  fi
else
  sudo cp -rvv lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf;
fi

if [ "$1" ] && [ "$1" = "--immudex" ]; then
  sudo mv /etc/lightdm/lightdm-gtk-greeter-immudex.conf /etc/lightdm/lightdm-gtk-greeter.conf;
else
  if [ -f /etc/lightdm/lightdm-gtk-greeter-immudex.conf ]; then
    sudo rm /etc/lightdm/lightdm-gtk-greeter-immudex.conf
  fi
  if [ "$NAME" = "Ubuntu" ]; then
    sudo sed -i 's,vendor/256x256/emblems/emblem-vendor.png,LoginIcons/apps/64/computer.svg,' /etc/lightdm/lightdm-gtk-greeter.conf;
  elif [ "$NAME" = "Arch Linux" ]; then
    sudo sed -i 's,/usr/share/icons/vendor/256x256/emblems/emblem-vendor.png,/usr/share/pixmaps/archlinux-logo.png,' /etc/lightdm/lightdm-gtk-greeter.conf;
  fi
fi

if [ ! "$NAME" = "Debian" ]; then
  sudo mkdir -p /usr/share/images/desktop-base;
fi

if [ -f /usr/share/images/desktop-base/default ]; then
  sudo rm /usr/share/images/desktop-base/default;
fi

sudo cp -rvv images/* /usr/share/images/desktop-base;
sudo ln -s /usr/share/images/desktop-base/d13_wallpaper.png /usr/share/images/desktop-base/default;

if [ "$NAME" = "Ubuntu" ]; then
  sudo mv /usr/share/xfce4/backdrops/xubuntu-wallpaper.png /usr/share/xfce4/backdrops/xubuntu-wallpaper.png.old;
  sudo ln -s /usr/share/images/desktop-base/d13_wallpaper.png /usr/share/xfce4/backdrops/xubuntu-wallpaper.png;
fi

if [ -f /usr/share/backgrounds/xfce/xfce-x.svg ]; then
  sudo rm /usr/share/backgrounds/xfce/xfce-x.svg;
  sudo ln -s /usr/share/images/desktop-base/d13_wallpaper.png /usr/share/backgrounds/xfce/xfce-x.svg;
fi

sudo sed -i 's/lightdm_wallpaper.jpg/d13_wallpaper.png/' /etc/lightdm/lightdm-gtk-greeter.conf;

cat >> distro-name <<EOF
#!/bin/bash

source /etc/os-release;
if [ "\$NAME" = "Alpine Linux" ]; then
  echo "\$PRETTY_NAME";
else
  echo "\$NAME \$VERSION";
fi
EOF

sudo cp distro-name /usr/local/bin;
sudo chmod +x /usr/local/bin/distro-name;
