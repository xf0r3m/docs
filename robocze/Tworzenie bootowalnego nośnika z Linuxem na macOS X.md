# Tworzenie bootowalnego nośnika z Linuxem na macOS X

1. Określenie numeru dysku
```
$ diskutil list
```

2. Przygotowanie nośnika
```
$ diskutil eraseDisk <system_plików> <etykieta_dysku> [schemat_partycjonowania] disk<numer_dysku>
```

3. Przygowanianie obrazu
```
$ hdiutil convert -format UDRW -o <nazwa_pliku_iso.dmg> <nazwa_pliku_iso.iso>
```

4. Wysuwanie nośnika z systemu
```
$ diskutil unmountDisk /dev/disk<numer_dysku>
```

5. Zapisanie obrazu na nośniku
```
$ sudo dd if=<nazwa_pliku_iso.dmg> of=/dev/rdisk<numer_dysku> bs=1m
```
