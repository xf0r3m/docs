#!/bin/bash

function fillWithSpaces() {
  x=1;
  while [ $x -le $1 ]; do
    echo -n ' ';
    x=$((x + 1));
  done
}

if ip a | grep -q 'wlan[0-9]*'; then
  if [ "$1" ]; then 
    wlansList=$1;
  else 
    sudo /usr/sbin/iwlist wlan0 scan > /tmp/wlanList.txt;
    wlansList="/tmp/wlanList.txt";
  fi
  countWlans=$(grep 'Cell\ [0-9]*' $wlansList | tail -1 | awk '{printf $2}');
  if echo $countWlans | grep -q '^0'; then
    countWlans=$(echo $countWlans | cut -c 2);
  fi
  i=1;
echo "LP.| ESSID                             | FREQ |  CHAN. | SIG. | SEC. |";
echo "---+-----------------------------------+------+--------+------+------+";
  while [ $i -le $countWlans ]; do
    if [ $i -lt 10 ]; then
      l="0${i}"
    else
      l=$i;
    fi

    if [ $i -eq $countWlans ]; then
            endValue=$(wc -l $wlansList | awk '{printf $1}');
    else
      startValue=$(grep -n "Cell\ ${l}" $wlansList | cut -d ":" -f 1);
      j=$((i + 1));
      if [ $j -lt 10 ]; then k="0${j}"; else k=$j; fi
      endValue=$(grep -n "Cell\ ${k}" $wlansList | cut -d ":" -f 1);
      essid=$(sed -n "${startValue},${endValue}p" $wlansList | grep "ESSID\:" | cut -d ":" -f 2);
      if [ $(echo $essid | wc -c) -lt 35 ]; then
        sub=$((35 - $(echo $essid | wc -c))); 
        essid=$(echo "${essid}$(fillWithSpaces $sub)");
      fi 
      freq=$(sed -n "${startValue},${endValue}p" $wlansList | grep "Frequency\:" | cut -d ":" -f 2)
      if echo $freq | cut -d "." -f 1 | grep -q '5'; then freq="5GHz";
      else freq="2.4GHz"; fi
      if sed -n "${startValue},${endValue}p" $wlansList | grep -q "Encryption\ key:on"; then
        if sed -n "${startValue},${endValue}p" $wlansList | grep -q "WPA2"; then
          sec="WPA2";
        elif sed -n "${startValue},${endValue}p" $wlansList | grep -q "WPA"; then
          sec="WPA1";
        elif sed -n "${startValue},${endValue}p" $wlansList | grep -q "WPA3"; then
          sec="WPA3";
        else
          sec="WEP";
        fi
      else
        sec="OPEN";
      fi
      signal=$(sed -n "${startValue},${endValue}p" $wlansList | grep -o "level=\-[0-9]*\ dBm" | cut -d "=" -f 2 | sed 's/ //g');
      channel=$(sed -n "${startValue},${endValue}p" $wlansList | grep 'Channel\:[0-9]*' | cut -d ":" -f 2);
      channel=$(echo "CH: ${channel}");
      echo -e "${l}: ${essid}\t${freq}\t${channel}\t${signal}\t${sec}";
    fi
    i=$((i + 1));  
  done
fi
