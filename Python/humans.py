#!/usr/bin/env python3

class Human():
  def __init__(self,firstname,lastname,age,sex):
    self.firstname = firstname
    self.lastname = lastname
    self.age = int(age)
    self.sex = sex
    self.origin = 'USA'

  def showHumanAttr(self):
    print(f"Firstname: {self.firstname}")
    print(f"Lastname: {self.lastname}")
    print(f"Age: {self.age}")
    print(f"Sex: {self.sex}")
    print(f"Origin: {self.origin}")

  def changeOrigin(self, newOrigin):
    self.origin = newOrigin

  def happyBirthday(self):
    print(f"Happy Birthday, {self.firstname}!")
    self.age+=1

def hello(human):
  print(f"Witaj, {human.firstname} {human.lastname}")

John =  Human('John', 'Doe', '35', 'Male')

John.showHumanAttr()

hello(John)

John.changeOrigin('Poland')

John.happyBirthday()

John.showHumanAttr()
