#!/usr/bin/env python3.11

#Python. Ćwiczenia - xf0r3m - 01.01.2023

#2.4. Wielkość liter w imionach
#Zapisz w zmiennej imię osoby, a następnie wyświetl je za pomocą małych liter,
#wielkich liter oraz z użyciem wielkiej litery jako pierwszej litery imienia. 

name = "jakub";

print(f"Wyświetlenie imienia z pierwszą wielką literą: {name.title()}")
print(f"Wyświetlenie imienia wielkimi literami: {name.upper()}")

name = "JAKUB";
print(f"Wyświetlenie imienia małymi literami: {name.lower()}")
