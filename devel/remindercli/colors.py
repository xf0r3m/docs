#!/usr/bin/env python3

endc = '\033[0m'

RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'

for i in range(0,100):
	color = f"\033[{i}m"
	print(f"{i}: {color}Test{endc}")

print(f"{RED}Tekst jest czerwony{endc}")
print(f"{GREEN}Tekst jest zielony{endc}")
print(f"{YELLOW}Tekst jest zółty{endc}")
print(f"Tekst jest pisany zgodnie z ustawieniami terminala")
