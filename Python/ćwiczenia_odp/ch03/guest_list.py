#!/usr/bin/env python3.11

#Python. Ćwiczenia - xf0r3m - 01.01.2023

#3.4. Lista gości
#Jeżeli mógłbyś zaprosić kogokolwiek na obiad, żyjącego lub nieżyjącego, to 
#kogo byś zaprosił? Utwórz listę zawierającą przynajmniej trzy osoby, które 
#chciałbyś zaprosić na obiad. Następnie wykorzystaj tę listę do wyświetlenia 
#dla każdej z tych osób komunikatu zapraszającego ją na obiad.

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
  
guests = ['Aleksandra Nowak', 'Piotr Kowalski', 'Tomasz Nowakowski'];
for guest in guests:
  changed_guest = change_names(guest)
  print(f"Zapraszam na obiad {changed_guest}")

