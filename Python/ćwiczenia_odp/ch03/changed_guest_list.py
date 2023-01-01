#!/usr/bin/env python3.11

#Python. Ćwiczenia - xf0r3m - 01.01.2023

#3.5. Zmiana listy gości
#Dowiedziałeś się, że jedna z zaproszonych osób nie może przyjść na obiad. 
#Konieczne jest więc wysłanie następnych zaproszeń. Zastanów się, kogo w takim 
#razie jeszcze zaprosisz.
    #Pracę rozpocznij od programu utworzonego w ćwiczeniu 3.4. Na jego końcu 
    #umieść polecenie print() wyświetlające komunikat z informacją, który z 
    #zaproszonych gości nie może przyjść.
    #Zmodyfikuj listę i dane gościa, który nie będzie mógł przybyć na obiad,
    #zastąp danymi nowej zaproszonej osoby.
    #Wyświetl drugi zestaw komunikatów z zaproszeniem, po jednym komunikacie 
    #dla każdej osoby znajdującej się na liście.

from random import randint

def change_names(arg):
  name_surname=arg.split()
  name=name_surname[0]
  surname=name_surname[1]

  if name[-1] == "a":
    newname=name[:-1]
    newname = newname + 'ę'
    name = newname
  elif surname[-1] != 'i' and surname[-1] != 'o':
    name = name + 'a'
    surname = surname + 'a'
  elif surname[-1] == 'o':
    name = name + 'a'
  else:
    name = name + 'a'
    surname = surname + 'ego'
 
  newarg = name + ' ' + surname
  return newarg

def print_guests(arg_list):
  for arg in arg_list:
    changed_guest = change_names(arg)
    print(f"Zapraszam na obiad {changed_guest}")
  
guests = ['Aleksandra Nowak', 'Piotr Kowalski', 'Tomasz Nowakowski']
print_guests(guests)

absence_guest=randint(0,2)
print(f"{guests[absence_guest]}, niestety nie przyjdzie na obiad")

del guests[absence_guest]
new_guest="Wojciech Łuszczyk"
guests.insert(absence_guest, new_guest)

print_guests(guests)
