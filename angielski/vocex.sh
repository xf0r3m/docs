#!/bin/bash

points=0;
vocFile=/tmp/voc;
userAnsFile=/tmp/userAns;

if [ -f $1 ]; then
  cp $1 /tmp/${1}.tmp;
  sourceFile=/tmp/${1}.tmp;
	sourceFileNOL=$(wc -l $sourceFile | awk '{printf $1}');
  pointsToGet=$sourceFileNOL;
  
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
  
    echo $voc >> $vocFile;
    echo $userAns >> $userAnsFile;
    sed -i "${randomLineNo}d" $sourceFile
    sourceFileNOL=$((sourceFileNOL - 1));
  done

  pointsPercentage=$(echo "print(${points}/${pointsToGet})" | python3);
  if [ $(echo $pointsPrecentage | cut -c 1) -eq 1 ]; then
    result=100;
  else 
    roundIndicator=$(echo "$pointPercentage" | cut -c 5);
    result=$(echo "$pointPercentage" | cut -c 3-4);
    if [ $roundIndicator -ge 5 ]; then result=$((result + 1)); fi
  fi
  if [ $result -ge 98 ] && [ $result -le 100 ]; then grad=6;
  elif [ $result -ge 86 ] && [ $result -le 97 ]; then grad=5;
  elif [ $result -ge 66 ] && [ $result -le 85 ]; then grad=4;
  elif [ $result -ge 50 ] && [ $result -le 65 ]; then grad=3;
  elif [ $result -ge 30 ] && [ $result -le 49 ]; then grad=2;
  else grad=1;
  fi  
 
  echo "${points}/${pointsToGet} = $result = $grad"; 
  rm $sourceFile;
  rm $vocFile;
  rm $userAnsFile;
else
	echo "Source file is needed to run a vocabulary exam";
fi
