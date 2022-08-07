#!/bin/bash
# Entering to home dir.
cd $HOME;

# Installation of graphical environment:
sudo pacman -Sy xorg fluxbox xorg-xinit xterm slim archlinux-wallpaper;

# Enabling slim.service unit:
sudo systemctl enable slim.service;

# Installation of needed software:
sudo pacman -Sy qutebrowser firefox shotwell gimp qmmp vlc arandr pulseaudio pavucontrol xscreensaver ranger htop neofetch zathura zathura-pdf-poppler leafpad virt-manager x11-ssh-askpass wget feh;

# Coping necessary data for fluxbox and other staff.
cp -prvv archflux/fluxbox ~/.fluxbox;
fmenuhostname=$(grep -o 'arch[0-9]*' ~/.fluxbox/menu);
sed -i "s/$fmenuhostname/$(cat /etc/hostname)/" ~/.fluxbox/menu;
sudo mv /usr/share/slim/themes/default/background.jpg /usr/share/slim/themes/default/background.jpg1;
sudo cp archflux/split.jpg /usr/share/slim/themes/default/background.jpg;
cp archflux/XTerm ~/XTerm;
cp archflux/vimrc ~/.vimrc;
sudo cp archflux/toggleTheme /usr/local/bin;
sudo chmod +x /usr/local/bin/toggleTheme;
sudo cp archflux/wall_style1_logo.png /usr/share/backgrounds
sudo cp archflux/gnome_wallpaper.jpg /usr/share/backgrounds

# Create .xinitrc and .xsession files.
echo "xscreensaver --no-splash &" > ~/.xinitrc
echo "feh --no-fehbg --bg-fill /usr/share/backgrounds/wall_style1_logo.png &" >> ~/.xinitrc;
echo "setxkbmap pl" >> ~/.xinitrc;
echo "exec startfluxbox" >> ~/.xinitrc;
cp ~/.xinitrc ~/.xsession

# Run neofetch after terminal session is started.
echo "/usr/bin/neofetch" >> ~/.bashrc; 

# Compilation and installation ncspot (spotify terminal client) from AUR:
sudo pacman -Sy dbus libpulse libxcb ncurses openssl alsa-lib cargo git pkgconf python rust base-devel;
git clone https://aur.archlinux.org/ncspot.git
cd ncspot;
makepkg -si
cd -

echo "Instalation of archflux is already done!. Now you can reboot your computer";
