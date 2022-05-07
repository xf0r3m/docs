# OpenBSD jako bramka
 
__UWAGA! Wszystkie polecenia tutaj są uruchamiane z poziomu użytkownika `root`__

1. Instalacja systemu
          
    Instalacja systemu OpenBSD została przedstawiona [tutaj](https://morketsmerke.net/instalacja-openbsd/). Jedyne co w tym wypadku można zmienić to ustawić interfejsy, czy dhpc czy static na interfejsie zewnętrznym oraz wybrać klasę prywatną dla interfejsu wewnętrznego.
    ```
    #Interfejs zewnętrzny
    IPv4 address for em0 ? (or 'dhcp' or 'none') [dhcp] 157.190.112.10
    Netmask for em0 [255.255.255.0]
    ```

    ```
    #Interfejs wewnętrzny
    IPv4 address for em1 ? (or 'dhcp' or 'none') [none] 192.168.0.1
    Netmask for em0 [255.255.255.0]
    ```

    Pamiętajmy że musimy ustawić, adres bramy domyślnej oraz serwery DNS, połączenie z Internetem jest konieczne aby móc zainstalować niezbędne oprogramowanie.
    ```
    Default IPv4 route ? (IPv4 address or none) [none] 157.190.112.1
    DNS domain name (e.g. 'example.com') [my.domain] morketsmerke.net
    DNS nameservers? (IP address list or none) 157.190.112.1
    ```

2. Instalacja dnsmasq
        
    W przypadku OpenBSD większość niezbędnego oprogramowania nie jest dołączona do systemu. Aby zainstalować cokolwiek w OpenBSD musimy dodać repozytorium żeby to zrobić wydajemy polecenie:
    ``` 
    export PKG_PATH="ftp://ftp.icm.edu.pl/pub/OpenBSD/6.5/packages/amd64"
    ```

    Możemy sprawdzić dostępność repozytorium wydając polecenie i podając jako argument jakikolwiek pakiet np. nano
    ```
    pkg_info -Q nano
    ```
    Po uzyskaniu odpowiedzi od programu, możemy teraz wydać odpowiednie polecenie aby zainstalować niezbędny program:
    ```
    pkg_add -a dnsmasq
    ```
    Po zainstalowaniu warto włączyć daemona do auto-startu.
    ```
    rcctl enable dnsmasq
    ```

3. Konfiguracja protokołu DHCP

    W OpenBSD plik konfiguracji dhcpd znajduje się bezpośrednio w katalogu`/etc`pod nazwą `dhcpd.conf`. Do zwykłej bramki nie potrzebujemy zbyt wielu opcji, nie licząc deklaracji podsieci, 3 lub 4. Cztery jeśli zdecydujemy się na lokalną domenę, klasycznie potrzebujemy zakresu, adresu bramy domyślnej i serwerów DNS:
    ```
    subnet 10.0.0.0 netmask 255.255.255.0 {
        range 10.0.0.100 10.0.0.250;
        option routers 10.0.0.1;
        option domain-name "morketsmerke.net";
        option domain-name-servers 10.0.0.1;
    }
    ```
    Deklaracje powtarzamy dla kolejnych interfejsów, jeśli są obecne i<br />
    wykorzystywane.

4. Ustawienie interfejsu dla dhcpd
    
    Konfiguracja daemona dhcpd polega głównie na wskazaniu interfejsu, na którym ma nasłuchiwać, dokonuje się tego w pliku `rc.conf.local` w `/etc` dopisując do niego opcję z wartość `dhcpd_flags="interfejs"`
    wpisanie w ten plik tej opcji, jest równoznaczne z dodaniem do auto-startu dhcpd, więc nie musimy wydawać polecenia `rcctl enabled` dla dhcpd.

5. Ustawienie interfejsu dla dnsmasq<br />

    W tym systemie robi się to podobnie jak w systemie Linux. Plik konfiguracyjny znajduje się w `/etc/dnsmasq.conf`. Odszukujemy w nim opcji `interface=`, odkomentowuje i wpisujemy interfejs na jakim ma nasłuchiwać. Opcje ewentualnie powtarzamy dla pozostałych interfejsów wewnętrznych.

6. Ewentualne wpisy do `/etc/hosts`
    
    Format: `IP FQDN SHORT_NAME`. Na przykład:
    ```
    192.168.0.10    serwer.morketsmerke.net serwer
    ```

7. Reguły firewall oraz NAT

    Za firewall w systemie OpenBSD odpowiada PF (PacketFilter), jego reguły są przechowywane w pliku `/etc/pf.conf`, prawdopodobnie znajdują się tam już jakieś reguły. Wszystkie je należy usunąć. Pierwszą czynnością będzie definicja makr (takie jakby zmienne).
    ```
    red="interfejs_zewnętrzny"
    green="interfejs_wewnętrzny"
    greennet="interfejs_wewnętrzny:network"
    ```
    Ponieważ PF działa z zasadą ostatni wygrywa, na pakietach pasujących do ostatniej z reguł zostanie podjęta zapisana w niej akcja (pass lub block). Możemy odciąć dostęp z sieci i do sieci podając regułę `block all` na początku zbioru zaraz po makrach. Przez to kolejne reguły z akcją `pass` będą dopuszcza/wypuszczać tylko ruch wybiórczo (tylko ten pasujący do reguły, reszta zostanie zablokowana) Teraz możemy dodać kolejno następne reguły już umożliwiające komunikację:
    * z sieci do bramki: `pass in on $green from $greennet to any`
    * Bramki z siecią zewnętrzną: `pass out on $red from $red to any`        
    * NAT: `pass out on $red from $greennet to any nat-to ($red)`
    Ten nawias przy ostatniej regule oznacza to że PF będzie na bieżąco monitorować interfejs po względem zamian, maskarada tylko że na BSD.

8. Przekazywanie pakietów

    Na koniec wystarczy uruchomić przekazywanie pakietów, a także ustawić uruchamianie przekazywania na autostarcie. Uruchomienie przekazywania:
    ```
    sysctl net.inet.ip.forwarding=1
    ```
    Zapisanie do pliku `/etc/sysctl.conf` przekazywania:
    ```
    echo 'net.inet.ip.forwarding=1' >> /etc/sysctl.conf
    ```

Teraz możemy cieszyć się bramką opartą o system OpenBSD.

