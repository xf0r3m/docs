# UP104D3R - VTMP

Skrypt do automatycznego publikowania maszyn wirtualnych.


## Wymagania:
* Logowanie użytkownika uruchomiającego plik 'upload.sh' musi być realizowane za pomocą kluczy 
	publicznych na serwer VTMP.
* Użytkownik zdalny musi być w grupie 'www-data', aby móc bez problemy pisać w katalogach
	serwera HTTP.
* Program 'rsync' musi być zainstalowany po obu stronach.

## Uwagi:
* Skrypt w założeniach monitoruje obecność interfejsu sieciowego USB0 (bazowo RPI 3B+ w raz z routerem
skonfigurownym na Tethering USB ze smartfona) oraz sam montuje pierwszą pamięć masową jako
pod '/media/usb0', z której pobierane będą maszyny wirtualne. W momencie wykrycia tych dwóch rzeczy
publikacja maszyn rozpoczyna się automatycznie. 
