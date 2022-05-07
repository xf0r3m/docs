# CDLCD
## Custom Debian LiveCD

Skrypt powłoki BASH pozwalający na utworzenie dostoswanego do naszych potrzeb
LiveCD z dystrybucją GNU/Linux Debian.

**Wymagania**
1. Dystrybucja GNU/Linux Debian lub oparta na nim wykorzystująca manager
pakietów APT.
2. Dostęp do konta użytkownika *root*

**Instalcja**
1. # git clone https://git.morketsmerke.net/xf0r3m/cdlcd.git
2. # chmod +x customDebianLiveCD.sh

**Konfiguracja**
1. W pliku customDebianLiveCD.sh:
  * Zmienna `LIVE_NAME` - nazwa dla LiveCD, pojawia się w kilku mało istonych
    miejscach
  * Zmienna `DEBIAN_MIRROR` - najbliższy mirror GNU/Linux Debian
2. W pliku chmodCommand.sh:
  * Zmienna `LIVE_NAME` - jw.
  * Zmienna `PKGS_LIST` - lista z nazwami paczek repozytorium do doinstalowania
    na LiveCD.
  * Zmienna `WALLPAPER_URL` - podanie url dla tapety środowiska graficznego

Generalnie cały plik chmodCommand.sh należy dostosować pod siebie, domyślnie 
plik zakłada użycie środowiska `icewm` i takie jest też zasugerowane w 
domyślniej liście pakietów, stąd również zasugerowanie zmiany tapety użyte w
kodzie. Można usunąć te właściwość. Poza `icewm`, obsługą sieci oraz klientem
SSH nie ma zbyt wielu domyślnych pakietów więc warto wziąć to pod uwagę.

**Aktualizacje**
Istnieje możliwość usunięcia pliku .squashfs oraz pliku .iso, i stworzenie ich
na nowo. Przydatne w przypadku trudnej do oskryptowania ingrencji pobrany
obraz Debiana. Służy do tego opcja `--upgrade`.

**Ingrencja w obraz Debiana**
Po zakończeniu pracy przez skrypt, możemy oczywiście dokonywać zmian w obrazie
za pomocą polecenia `# chmod ~/$LIVE_NAME/chroot` środowiwsko zostanie
przełączone i teraz można dokonywać innych zmian niż te zapisane w plik
chrootCommand.sh. Po zakończeniu pracy należy pamiętać aby wywołać skrypt
customDebianLiveCD.sh z opcja `--upgrade` aby wygenerować nowe pliki .squashfs
oraz .iso  
