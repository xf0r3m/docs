<h1>Instalacja greenOS</h1>

<p>
GreenOS dostarczany jest bez instalatora. Przez co daje ogromne możliwość
konfiguracji systemu przed jego pierwszym uruchomieniem. Instalacja składa
się z kilku poleceń.
</p>
<ol>
<li>
Uruchamiamy na naszej maszynie docelowej jakiegoś Linux-a w wersji Live,
może być to dowolna dystrybucja, którą akurat mamy pod ręką. Do instalacji
wykorzystywać będzięmy podstawowe narzędzia. GreenOS również jest dostępny
wersji LiveCD.
</li>
<li>
<p>
Instalacja greenOS wymaga połączenia z Internetem, skądś należy pobrać
paczkę z plikami katalogu głównego (rootfs). Oczywiście jeśli posiadamy
sterowniki w zbootowanym systemie. Jeśli posiadamy sterowniki do karty
Ethernet, to połączenie z internetem spowadza się do podłączenia kabla
następnie wydaniu polecnenia: `dhclient $interface`, gdzie `$interface` to
nazwa interfejsu sieci Ethernet w systemie, możemy sprawdzić ją za pomocą
polecenia `ip a`. Jeśli połączenie przewodowe nie jest dostępne, a mamy
możliwość skorzystania z sieci bezprzewowdowej (tj. mamy widoczną kartę
sieciową w systemie, oraz dostęp do jakiejś sieci bezprzewodowej), to
jeśli należy taką kartę włączyć za pomocą polecenia 
`ip link set $interface up`, `$interface` = interfejs sieci bezprzewodowej,
następnie przeskanować otoczenie w poszukiwaniu
sieci bezprzewodowej, do której mamy dostęp. Do tego celu należy użyć polcenia
`iwlist $interface scan`, z racji tego że potrzebujemy tylko SSID, a to
polecenie zwraca dużą ilość danych, należy przepuścić jej wyjście przez
polecenie `grep` z wyrażeniem "SSID", dzięki temu poleceniu reszta danych 
wyjściowych zostanie odfiltrowana, a wyświetlone zostaną tylko nazwy sieci
(SSID). W większości przypadków, połączenie się z siecią będzie wymagało
klucza, w zależności od użytch zabepieczeń różnić się będzie metoda
przyłączenia się do sieci. Jeśłi nasza sieć używa standardu WPA, wtenczas
należy użyć programu `wpa_supplicant`. Wymaga on pliku konfiguracyjnego,
w którym znajdują się deklaracje sieci. Plik ten generuje się przekierowując
standardowe wyjście polecenia `wpa_passphrase` do pliku. Plik może być
zapisany gdzie kolwiek, poleceniu `wpa_supplicant` i tak podajemy ściężkę
do niego. `wpa_passphrase` do wygenerowania plik musi mieć SSID sieci oraz
klucz PSK, podajemy te informacje jako argumenty pozycjne:
`wpa_passphrease RogueAP 123Test123 > wpa_supplicant.conf`. Po wygenerowaniu
pliku konfiguracyjnego 
</li>
                               ____  _____
   ____ _________  ___  ____  / __ \/ ___/
  / __ `/ ___/ _ \/ _ \/ __ \/ / / /\__ \ 
 / /_/ / /  /  __/  __/ / / / /_/ /___/ / 
 \__, /_/   \___/\___/_/ /_/\____//____/  
/____/                                    
