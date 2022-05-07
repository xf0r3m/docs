#!/bin/bash

USER_AGENT="\"Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalboot)\"";

firstLink=$1;
startEnum=$2;
endEnum=$3
outputDir=$4;

startFilename=$(basename $firstLink);
directoryLink=$(echo $firstLink | sed "s/$startFilename//");

while [ $startEnum -le $endEnum ]; do
  if [ $startEnum -lt 10 ]; then startEnum="0${startEnum}"; fi
  newFilename=$(echo $startFilename | sed "s/$(echo $startFilename | egrep -o '[0-9]{2}\.jpg')/${startEnum}.jpg/");
  wget --user-agent="$USER_AGENT" ${directoryLink}${newFilename} -O ${outputDir}/${newFilename};
  if [ $startEnum -lt 10 ] && [ $(echo $startEnum | wc -c ) -gt 1 ]; then 
    startEnum=$(echo $startEnum | cut -c 2);
  fi 
  startEnum=$((startEnum + 1));
done
