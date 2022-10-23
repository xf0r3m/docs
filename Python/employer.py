#!/usr/bin/env python

class Employee():
  def __init__(self,firstname,lastname,y_salary):
    self.firstname = firstname
    self.lastname = lastname
    self.y_salary = y_salary

  def give_raise(self,newSalary=5000):
    self.y_salary += newSalary

