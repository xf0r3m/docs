#!/usr/bin/env python3

import unittest
from employer import Employee

#new_employ = Employee('Jan', 'Nowak', 120_000)
#print(f"{new_employ.firstname} {new_employ.lastname}: {new_employ.y_salary}")

class EmployeeTest(unittest.TestCase):
  def setUp(self):
    firstname = 'John'
    lastname = 'Doe'
    y_salary = 120_000
    self.new_employee = Employee(firstname,lastname,y_salary)

  def test_give_default_raise(self):
    self.new_employee.give_raise()
    self.assertEqual(self.new_employee.y_salary, 125_000)

  def test_give_custom_salary(self):
    self.new_employee.give_raise(25_000)
    self.assertEqual(self.new_employee.y_salary, 145_000)

unittest.main()
