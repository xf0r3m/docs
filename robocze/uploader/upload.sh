#!/bin/bash

set -eu

vtmp_server="";
user="";

if ! ip a | grep -q 'usb0:' ; then 
	echo "Nie znaleziono interfejsu sieciowego usb0";
	exit 1;
else

	if ! mount | grep -q '/media/usb0' ; then
		echo "Nie znaleziono punktu montowania usb0";
		exit 1;
	else
		rsync -e 'ssh -p 2222' -avu /media/usb0/* ${user}@${vtmp_server}:/var/www/html/vms;
		ssh -t ${user}@${vtmp_server} -p 1963 "sudo chown -R www-data:www-data /var/www/html";
		ssh -t ${user}@${vtmp_server} -p 1963 "sudo chmod -R 775 /var/www/html";

	fi

fi
