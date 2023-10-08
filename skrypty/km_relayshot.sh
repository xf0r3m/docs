#!/bin/bash

if [ ! -d /sys/class/gpio/gpio17 ]; then
  echo 17 > /sys/class/gpio/export;
fi

echo out > /sys/class/gpio/gpio17/direction;
sleep 0.25;
echo 1 > /sys/class/gpio/gpio17/value;  
