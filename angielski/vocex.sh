#!/bin/bash

points=0;
vocFile=/tmp/voc;
userAnsFile=/tmp/userAns;
ansFile=/tmp/ansFile;

if [ -f $1 ]; then
  cp $1 /tmp/${1}.tmp;
  sourceFile=/tmp/${1}.tmp;
	sourceFileNOL=$(wc -l $sourceFile | awk '{printf $1}');
  pointsToGet=$sourceFileNOL;
  if [ -f $vocFile ]; then rm $vocFile; fi
  if [ -f $userAnsFile ]; then rm $userAnsFile; fi
  if [ -f $ansFile ]; then rm $ansFile; fi
  
  while [ $sourceFileNOL -gt 0 ]; do
    if [ $sourceFileNOL -eq 1 ]; then 
      randomLineNo=$(((RANDOM % sourceFileNOL) + 1));
    else
      randomLineNo=$(((RANDOM % (sourceFileNOL - 1)) + 1));
    fi
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

    if [ "$userAns" = "$answer" ]; then points=$((points + 1)); fi

    if [ "$2" ] && [ "$2" = "--trainingmode" ]; then
      if [ "$userAns" = "$answer" ]; then
        echo -e "\e[1;32mCORRECT\e[0m ${voc} = ${userAns}";
      else
        echo -e "\e[1;31mNOT CORRECT\e[0m ${voc} = \e[1;33m${userAns}\e[0m | \e[1;32m${answer}\e[0m";
      fi
    fi
  
    echo $voc >> $vocFile;
    echo $userAns >> $userAnsFile;
    echo $answer >> $ansFile;
    sed -i "${randomLineNo}d" $sourceFile
    sourceFileNOL=$((sourceFileNOL - 1));
  done
  
  #I sending division in below to python, because python3 in latest or other 
  #version is usually pre installed in main Linux distributions, what can't 
  #tell this about bc tool.
  pointsPercentage=$(echo "print(${points}/${pointsToGet})" | python3);
  
  if [ $(echo $pointsPercentage | cut -c 1) -eq 1 ]; then
    result=100;
  elif [ $(echo $pointsPercentage | cut -c 3) -eq 0 ]; then
    result=0;
  else 
    if [ $(echo "$pointsPercentage" | wc -c) -eq 4 ]; then
      result=$(echo "$pointsPercentage" | cut -c 3);
      result="${result}0";
    else
      roundIndicator=$(echo "$pointsPercentage" | cut -c 5);
      result=$(echo "$pointsPercentage" | cut -c 3-4);
      if [ $roundIndicator -ge 5 ]; then result=$((result + 1)); fi
    fi
  fi

  if [ $result -ge 98 ] && [ $result -le 100 ]; then grad=6; color="1;32";
  elif [ $result -ge 86 ] && [ $result -le 97 ]; then grad=5; color="1;33";
  elif [ $result -ge 66 ] && [ $result -le 85 ]; then grad=4; color="1;35";
  elif [ $result -ge 50 ] && [ $result -le 65 ]; then grad=3; color="1;34";
  elif [ $result -ge 30 ] && [ $result -le 49 ]; then grad=2; color="1;30";
  else grad=1; color="1;31";
  fi  
  
  echo -e "\e[${color}m${points}\e[0m/${pointsToGet} = \e[${color}m${result}\e[0m = \e[${color}m${grad}\e[0m" | tee /tmp/lastresult;
  #echo "${points}/${pointsToGet}=${result}=${grad}" >> /tmp/lastresult; 
  rm $sourceFile;

elif [ "$1" ] && [ "$1" = "--lastresult" ]; then
  vocNOL=$(wc -l $vocFile | awk '{printf $1}');
  i=1;
  while [ $i -le $vocNOL ]; do
    voc=$(sed -n "${i}p" $vocFile);
    userAns=$(sed -n "${i}p" $userAnsFile);
    answer=$(sed -n "${i}p" $ansFile); 
    echo -e "$voc = \e[1;33m${userAns}\e[0m | \e[1;32m${answer}\e[0m";
    i=$((i + 1));
  done
  echo -e "$(cat /tmp/lastresult)";
else
  echo "vocex.sh - vocabulary exam";
  echo "morketsmerke.github.io @ 2022";
  echo "Usage:"
  echo "dictionary_file.txt - runs vocabulary exam based on dictionary file";
  echo "dictionary_file.txt --trainingmode - runs learning mode (modified vocabulary exam)";
  echo "--lastresult - print last exam with asked word, users answers, correct answers summary result";
	echo "Source file is needed to run a vocabulary exam";
fi
