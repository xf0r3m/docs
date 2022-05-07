#!/bin/bash
disk_name='sda'
part_count=$(lsblk /dev/$disk_name | grep "part" | wc -l | awk '{printf $1}')
                                    i=1;
                                    while [ $i -le $part_count ]; do
                                        
                                        part=$(lsblk /dev/$disk_name | grep 'part' | sed -n ${i}p | awk '{printf $1}' | grep -o '[a-z]*[0-9]');
                                        fs_type=$(fdisk -l /dev/$disk_name | grep $part | awk '{printf $7}');

                                        case $fs_type in
                                            'Linux') echo "EXT4";;
                                            'HPFS/NTFS/exFAT') echo "NTFS";;
                                            'W95') echo "FAT32";;
                                            *) echo "Nie wspierany system plików";;
                                        esac

                                        i=$(expr $i + 1)
                                    done