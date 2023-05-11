#!/bin/bash

gpio mode 0 output;

if [ "$1" ]; then

	if [ "$1" = "on" ]; then 

		gpio write 0 0;

	else
		gpio write 0 1;
	fi

fi
