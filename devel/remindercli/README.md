# REMIDER - zarządzanie przypomnienieniami w terminalu.

REMINDER to prosty skrypt służący zarządzaniu i wyświetlaniu przypomnień.
Przypomnienia dodaje się z poziomu terminala, są one wyświetlane w systemie
za pomocą pakietu "notify-send".

1. Instalacja

	```
	1. git clone https://git.morketsmerke.net/xf0r3m/reminder.git
	2. cd reminder
	3. chmod +x reminder.sh
	3. ./reminder.sh install
	```

2. Dostępne opcje

	* `add <nazwa> <data_przypomnienia> <czas_powiadomienia_przed_zadeklarowanym_terminem> [lokalizacji]` - Dodaje przypomnienie

	* `list` - Wyświetla dodane powiadomienia w formacje wskazanym poniżej.

	* `delete <identyfikator_przyponienia>` - Usuwa przypomnienia

	* `remindme` - Uruchamia przypominanie

	* `confirm <identyfikator_przypomnienia>` - Potwierdza odczytanie powiadomienia przez użytkownika. Zatrzymuje wyświetlanie powiadomień, w przeciwnym razie powiadomienie będzie wyświetlać się co minutę.
	
	* `install` - Instaluje skrypt w systemie.

3. Format listy przypomnień:
	 
	```
	[identyfikator_powiadomienia]: [nazwa]
	Data: [data przypomnienia]
	Przypomnij: [czas powiadamiania prze zdeklarowanym terminem] przed
	Lokalizacja: [lokalizacja]
	```

4. Format danych wejściowych:

	* Data przypomnienia: `YYYY-MM-DD HH:MM`
	* Czas powiadamiania: np. 00:30 dla 30 minut; 01:00 dla 1 godziny
	* Lokalizacji: Lokalizacja jest opcjonalna. W przypadku jej braku
		zostanie wyświetlone Bd.
