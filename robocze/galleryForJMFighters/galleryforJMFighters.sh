#!/bin/bash

USER_AGENT="\"Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalboot)\"";

i=1;
page=$1;
end=$2;

while [ $i -lt $end ]; do
  bash wgetaspetalbot.sh $page
  if [ $i -lt 3 ]; then
    CSPlink=$(grep 'img\.joemonster\.org' index.html | cut -d '"' -f 2 | sed -n 's/large_thumb_//g;1p');
    wget --user-agent="$USER_AGENT" $CSPlink -O images/gallery_image$((i-1)).jpg;
    CSNlink=$(grep 'img\.joemonster\.org' index.html | cut -d '"' -f 2 | sed -n 's/large_thumb_//g;2p');
    wget --user-agent="$USER_AGENT" $CSNlink -O images/gallery_image$((i+1)).jpg;
  else
    CSNlink=$(grep 'img\.joemonster\.org' index.html | cut -d '"' -f 2 | sed -n 's/large_thumb_//g;2p');
    wget --user-agent="$USER_AGENT" $CSNlink -O images/gallery_image$((i+1)).jpg;
  fi
  nextPage=$(grep 'swipe-right"' index.html | cut -d '"' -f 4);
  page="https://joemonster.org${nextPage}";
  i=$((i+1));
done


