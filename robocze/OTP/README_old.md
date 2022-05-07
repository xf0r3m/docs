# dC-install

## W przypadku użycia w celu instalcji OTP:
1. $ sce-load bash
2. $ dC-install OTP /mnt/sr0 /dev/sda

## W przypadku użycia w celu instalacji dCore

## Wymagania
* git
* bash
* fdisk
* e2fsprogs
* extlinux

**Wszystkie te rozszerzenia muszą być załadowane w momencie uruchomienia
polecenia poza rozszerzeniem git**

# Do wydania stosownej wersji odradza się wykorzystanie dC-install do instalacji dCore.

---

## Instalacja
1. git clone https://github.com/xf0r3m/dC-install.git

## Użycie
`bash -x ~/dC-install/dC-install.sh dCore /urządzenie_z_nośnikiem_instalacji /docelowy_dysk_do_instalacji | tee ~/dC-install/dC-install.sh.log`

### Przykład:
`bash -x ~/dC-install/dC-install.sh dCore /dev/sr0 /dev/sda | tee ~/dC-install/dC-install.sh.log`
