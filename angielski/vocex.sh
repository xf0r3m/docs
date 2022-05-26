#!/bin/bash

points=0;
vocFile=/tmp/voc;
userAnsFile=/tmp/userAns;

if [ -f $1 ]; then
  cp $1 /tmp/${1}.tmp;
  sourceFile=/tmp/${1}.tmp;
	sourceFileNOL=$(wc -l $sourceFile | awk '{printf $1}');
  randomLineNo=$(((RANDOM % (sourceFileNOL - 1)) + 1));
  randomLang=$(((RANDOM % 2) + 1));
  voc=$(sed -n "${randomLineNo}p" $sourceFile | cut -d "=" -f $randomLang);
  echo -n "$voc = ";
  read userAns;
  if [ $randomLang -eq 1 ]; then
    answerLang=2;
  else
    answerLang=1;
  fi
  answer=$(sed -n "${randomLineNo}p" $sourceFile | cut -d "=" -f $answerLang);
  if [ $userAns = $answer ]; then
    if [ "$points" ]; then
      points=1;
    else
      points=$((points + 1));
    fi
  fi
  echo $voc >> $vocFile;
  echo $userAns >> $userAnsFile;
  

  rm $sourceFile;
  rm $vocFile;
  rm $userAnsFile;
else
	echo "Source file is needed to run a vocabulary exam";

