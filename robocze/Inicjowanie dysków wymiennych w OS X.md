# Inicjowanie dysków wymiennych w macOS X

W macOS X, inicjowanie czy też potoczne formatowanie dysków wymiennych, urządzeń typu pendrive czy dysk zewnętrzny sprowadza się do wydania jednego polecenia z odpowiednimi opcjami.

```
$ diskutil eraseDisk <system_plików> <etykieta_dysku> [schemat_partycjonowania] disk<numer_dysku>
```

* Schematy partycjonowania:
    * `APM` - Apple Partition Map
    * `MBR` - Master Boot Record
    * `GPT` - GUID Partitioning Table

* Systemy plików:
    * `APFSX` - APFS (z rozróżnianiem wielkości liter)
    * `APFS / APFSI` - APFS (bez rozróżniania wielkości liter)
    * `ExFAT` - ExFAT
    * `MS-DOS` - MS-DOS (FAT)
    * `MS-DOS FAT12` - MS-DOS (FAT12)
    * `MS-DOS FAT16` - MS-DOS (FAT16)
    * `MS-DOS FAT32 / FAT32` - MS-DOS (FAT32)
    * `HFS+` - Mac OS Extened (bez rozróżniania wielkości liter)
    * `HFSX` - Mac OS Extened (z rozróżnianiem wielkości liter)
    * `JHFSX` - Mac OS Extened (z rozróżnianiem wielkości liter oraz kronikowaniem)
    * `JHFS+` - Mac OS Extened (bez rozróżniania wielkości liter oraz z kronikowaniem)
    * `FREE` - Wolne miejsce