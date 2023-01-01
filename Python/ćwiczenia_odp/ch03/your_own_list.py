#!/usr/bin/env python3.11

#Python. Ćwiczenia - xf0r3m - 01.01.2023

#3.3. Twoja własna lista
#Zastanów się nad ulubionymi środkami transportu, na przykład motocykl lub 
#samochód, a następnie utwórz listę przechowującą wiele przykładów. Wykorzystaj
#tę listę do wyświetlenia kilku zdań o jej elementach, na przykład 
#„Chciałbym mieć motocykl Honda”.

cars = ["audi", "bmw", "toyota", "honda", "nissan", "mitsubishi"];
for car in cars:
  if car == "bmw":
    print(f"Podobają mi się samochody marki {car.upper()}")
  else:
    print(f"Chciałbym mieć samochód marki {car.title()}")
