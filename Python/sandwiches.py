#!/usr/bin/env python3

def make_sandwich(*toppings):
  print("Making sandwich...")
  for topping in toppings:
    print(f"Adding: {topping}")
  print("Sandwich is ready.")

