#!/usr/bin/env python3.11

#Python. Ćwiczenia - xf0r3m - 01.01.2023

#2.7. Usunięcie białych znaków z imienia
#Zapisz w zmiennej imię osoby wraz z pewnymi białymi znakami na początku i 
#końcu imienia. Upewnij się, że co najmniej raz użyłeś sekwencji \t i \n.
#Wyświetl to imię wraz ze znakami odstępu. Następnie wyświetl je jeszcze trzy 
#razy, ale za każdym razem wykorzystaj jedną z metod przeznaczonych do usuwania
#białych znaków: lstrip(), rstrip() i strip().


name = "\t\n\tJakub\t\n\t"

print(f"{name}");
print(f"LSTRIP: {name.lstrip()}");
print(f"RSTRIP: {name.rstrip()}");
print(f"STRIP: {name.strip()}");
