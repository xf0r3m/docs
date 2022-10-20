#!/usr/bin/env python3

class User():
  def __init__(self,login,password,email,dName):
    self.login = login
    self.password = password
    self.email = email
    self.dName = dName
    self.rank = 'user'
    self.quota = 1_000_000
    self.permissions = Permissions(self.rank)

  def changeRank(self,newRank):
    self.rank = newRank

  def checkQuota(self):
    if self.quota < 0:
      print("Unlimited");
    else:
      print("100MB")

class Permissions():
  def __init__(self,rank):
    if rank == 'Admin':
      self.permissions = ['add', 'delete', 'ban']
    else:
      self.permissions = ['add', 'delete']

  def showPermissions(self):
    for permission in self.permissions:
      print(f"- {permission}")

class Admin(User):
  def __init__(self,login,password,email,dName):
    super().__init__(login,password,email,dName)
    self.rank = 'Admin'
    self.quota = -1
    self.permissions = Permissions(self.rank);

  def banUser(self,userLogin):
    print(f"Administrator: {self.login}, zablokował użytkownika: {userLogin}")

John = User('John2000', 'Passw0rd', 'jdoe@yahoo.com', 'John Doe')
John.permissions.showPermissions()
John.checkQuota()

Tim = Admin('TimOver9k', '123admin123', 'tim@aol.com', 'Timmy Tim')
Tim.permissions.showPermissions()
Tim.banUser('John2000')
Tim.checkQuota()
