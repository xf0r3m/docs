#!/bin/bash


while true; do

dialog --backtitle "greenOS" --clear --no-mouse --no-cancel \
--title "${USER}@$(hostname)" --menu \
"Menu główne greenOS, aby uruchomić program wybierz pozycje z menu poniżej" \
15 75 10 "BASH" "Powłoka BASH" "w3m" "Tekstowa przeglądarka WWW" \
"mc" "Menadżer plików" "mutt" "Klient pocztowy" \
"vim" "Edytor tekstu" "mocp" "Odtwarzacz audio" \
"irrsi" "Klient sieci IRC" \
"reboot" "Uruchom komputer ponownie" "poweroff" "Zamknij system" \
2>menu;

ch=$(cat menu);
rm menu;

case $ch in
  "BASH") bash;;
  "w3m") w3m;;
  "mc") mc;;
  "mutt") mutt;;
  "vim") vim;;
  "mocp") mocp;;
  "irssi") irssi;;
  "reboot") sudo reboot;;
  "poweroff") sudo poweroff;;
esac

done
