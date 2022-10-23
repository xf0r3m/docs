#!/usr/bin/env python3

import unittest
from city_functions import city_countries

class testCityFunctions(unittest.TestCase):
  def test_city_countries(self):
    cc = city_countries('warszawa', 'polska')
    self.assertEqual(cc,'Warszawa, Polska')

unittest.main()
