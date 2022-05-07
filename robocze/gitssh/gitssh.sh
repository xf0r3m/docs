#!/bin/bash

user="";
email="";
remoteUser="";
server="";
dumbHTTPServer=""

if [ "$2" ]; then 

while getopts c:d:p: options; do
  case "${options}" in
    c) projectName=${OPTARG};
      echo -n "Opis projektu (opcjonalnie):"
      read desc;
      echo;
      echo "[i] Tworzenie projektu.";
      ssh ${user}@${server} -C "sudo su -s /bin/bash - git -c \"mkdir ~/${projectName}.git && cd ~/${projectName}.git && git --bare init\"";
      if [ "$desc" ]; then
        echo "[i] Dodawania opisu projektu do repozytorium";
        ssh ${user}@${server} -C "sudo su -s /bin/bash - git -c \"echo ${desc} > ~/${projectName}.git/description\"";
      fi;;
    d) projectName=${OPTARG};
      git clone http://${dumbHTTPServer}/${projectName}.git;
      cd ${projectName};
      git config user.name ${user};
      git config user.email ${email};
      git remote set-url origin ssh://${remoteUser}@${server}/~/${projectName}.git;;
      
    p) projectName=${OPTARG};
      ssh ${user}@${server} -C "if [ -d /var/www/pubgit/${projectName}.git ]; then rm -rf /var/www/pubgit/${projectName}.git; fi; cd /var/www/pubgit && git clone --bare /home/git/${projectName} ${projectName}.git && mv ${projectName}.git/hooks/post-update.sample ${projectName}.git/hooks/post-update && chmod a+x ${projectName}.git/hooks/post-update; cd ${projectName}.git && git update-server-info";;
  esac
done
else
  echo "gitssh - skrypt do obsługi repozytorium git przez ssh";
  echo "morketsmerke.net @ 2022";
  echo;
  echo -e "\t-c <nazwa_projektu> - tworzy nowe repozytorium na serwerze. Skrypt zapyta o opis projektu, jest on opcjonalny i można go pominąć.";
  echo -e "\t-d <nazwa_projektu> - klonowanie repozytorium";
  echo -e "\t-p <nazwa_projektu> - upublicznienie repozytorium do klonowania";
fi

