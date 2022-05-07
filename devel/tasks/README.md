# TASKS - Zarzadzanie zadaniami


Tasks to niewielki skrypt, ktorego zadaniem jest zarządzanie zadaniami
w stylu Kanban.

1. Instalacja:

	```
	1. git clone https://git.morketsmerke.net/xf0r3m/tasks.git
	2. cd tasks
	3. chmod +x tasks.sh
	4. ./tasks.sh install
	```

2. Dostępne opcje:

	* `createproject <nazwa_projektu>` - Tworzy nowy projekt.

	* `listprojects` - Wyświetla obecne projekty.

	* `deleteproject <nazwa_projektu / all>` - Usuwa jeden projekt wg. podanej nazwy
		lub wszystkie.

	* `createtask <nazwa_projektu> <nazwa_zadania>` - Tworzy nowe zadanie w projekcie
		(automatycznie w tabeli)

	* `markas <sciezka_zadania> <docelowa_tabela>` - Przenosi zadania między tabelami
		do dajac do zadań różne wartości: czas rozpoczęcia - w przypadku przeniesienia
		do tabeli "doing", czas zakończenia - w przypadku przeniesienia do tabeli
		"done", wartości te mogą zostać usunięte poprzez przeniesienie zadania do
		tabeli "todo".

	* `listtasks <nazwa_projektu>` - Wyświetla zadania danego projektu.

	* `deletetask <nazwa_projektu/todo|doing|done/id_zadania|all>` - usuwa konkretne badź
		wszyskie zadania z tabeli.

	* `addadnote <sciezka_zadania> <tresc_komentarza>` - Dodaje komentarz/adnotacje.

	* `details <sciezka_zadania>` - Wyświetla zadanie wraz z czasami dla odpowiednich tabel
		oraz adnotacjami.

3. Wyjaśnienie niektórych wartości:

	* `<sciezka_zadania>` - ciąg znaków składający się z nazwy projektu, tabeli (todo/doing/done)		oraz identyfikatora zadania.
