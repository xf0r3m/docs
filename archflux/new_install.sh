#!/bin/bash
# Setting timezone -> Europe/Warsaw
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime;

# Setting locales to generate
sed -i '/^#pl_PL.UTF-8 UTF-8/s/#//' /etc/locale.gen;
locale-gen;

# Setting LANG variable in /etc/locale.conf
echo "LANG=pl_PL.UTF-8" > /etc/locale.conf;

# Setting displaying polish signs in virtual console:
echo "KEYMAP=pl" > /etc/vconsole.conf;
echo "FONT=lat2-16" >> /etc/vconsole.conf;
echo "FONTMAP=8859-2" >> /etc/vconsole.conf;

# Setting hostname based on release date new Arch Linux version.
# Now is: 2022.08.05 so hostname will be: arch805.
echo "arch805" > /etc/hostname;

# Enabling Network Manager unit.
systemctl enable NetworkManager.service;

# Setting root password:
passwd root;

# Create user account and set password for him.
USER='xf0r3m';
useradd -m $USER;
passwd $USER;

# Instalation of sudo and increasing persmissions of new created user.
pacman -Sy sudo;
echo "$USER ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers;

cd /home/$USER;

# Installation of graphical environment:
sudo pacman -Sy xorg fluxbox xorg-xinit xterm slim archlinux-wallpaper;

# Enabling slim.service unit:
sudo systemctl enable slim.service;

# Installation of needed software:
sudo pacman -Sy qutebrowser firefox shotwell gimp qmmp vlc arandr pulseaudio pavucontrol xscreensaver ranger htop neofetch zathura zathura-pdf-poppler leafpad virt-manager x11-ssh-askpass wget feh;

# Coping necessary data for fluxbox and other staff.
cp -prvv /archflux/fluxbox /home/${USER}/.fluxbox;
fmenuhostname=$(grep -o 'arch[0-9]*' /home/${USER}/.fluxbox/menu);
sed -i "s/$fmenuhostname/$(cat /etc/hostname)/" /home/${USER}/.fluxbox/menu;
sudo mv /usr/share/slim/themes/default/background.jpg /usr/share/slim/themes/default/background.jpg1;
sudo cp /archflux/split.jpg /usr/share/slim/themes/default/background.jpg;
cp /archflux/XTerm /home/${USER}/XTerm;
cp /archflux/vimrc /home/${USER}/.vimrc;
sudo cp /archflux/toggleTheme /usr/local/bin;
sudo chmod +x /usr/local/bin/toggleTheme;
sudo cp /archflux/wall_style1_logo.png /usr/share/backgrounds
sudo cp /archflux/gnome_wallpaper.jpg /usr/share/backgrounds


# Create .xinitrc and .xsession files.
echo "xscreensaver --no-splash &" > /home/${USER}/.xinitrc
echo "feh --no-fehbg --bg-fill /usr/share/backgrounds/wall_style1_logo.png &" >> /home/${USER}/.xinitrc;
echo "setxkbmap pl" >> /home/${USER}/.xinitrc;
echo "exec startfluxbox" >> /home/${USER}/.xinitrc;
cp /home/${USER}/.xinitrc /home/${USER}/.xsession

# Run neofetch after terminal session is started.
echo "/usr/bin/neofetch" >> /home/${USER}/.bashrc; 

# Instalation dependencies for ncspot (spotify terminal client) from AUR:
sudo pacman -Sy dbus libpulse libxcb ncurses openssl alsa-lib cargo git pkgconf python rust base-devel;
git clone https://aur.archlinux.org/ncspot.git
# Setting propriate property
sudo chown -R ${USER}:${USER} /home/${USER}

# Compilation and instalation ncspot from AUR:
cd ncspot;
su $USER -c 'makepkg -si';
cd -

echo "Instalation of archflux is already done!.";
echo "If you need, make other chroot-installation tasks";
