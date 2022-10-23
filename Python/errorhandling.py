#!/usr/bin/env python3

try:
  open('filename3.txt')
except FileNotFoundError:
  with open('filename3.txt', 'w') as f:
    f.write('xf0r3m-3')
else:
  with open('filename3.txt') as f:
    plik = f.read()
    print(plik)
