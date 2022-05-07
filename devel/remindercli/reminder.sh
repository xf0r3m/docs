#!/bin/bash

filename="$HOME/.reminder";

if [ ! -f "$filename" ]; then touch "$filename"; fi

endColor="\033[0m";

if [ "$1" ]; then

	cmd=$1;
	case $cmd in
		'add') lastId=$(tail -n 1 "$filename" | cut -d ";" -f 1); 
			if [ ! "$lastId" ]; then lastId=0; fi
			id=$((lastId + 1));
			if [ "$2" ] && [ "$3" ] && [ "$4" ]; then
				name=$2;
				date=$3;
				if [[ ! $date =~ ^[0-9]{4}\-[0-9]{2}\-[0-9]{2}\ [0-9]{2}\:[0-9]{2}$ ]]; then
					echo "Niepoprawny format daty przypomnienia";
					exit 1;
				fi
				dateDate=$(echo "$date" | cut -d " " -f 1);
				dateYear=$(echo "$dateDate" | cut -d "-" -f 1);
				if [ "$dateYear" -gt 2025 ]; then
					echo "Data przypomnienia: Nie zalecenie jest używanie roku powyżej 2025.";
					exit 1;
				fi
				dateMonth=$(echo "$dateDate" | cut -d "-" -f 2);
				if [ "$dateMonth" -gt 12 ]; then
					echo "Data przypomnienia: Nie możliwe jest używanie miesiąca powyzej 12-tego.";
					exit 1;
				fi
				if [ "$dateMonth" -lt 10 ]; then dateMonth=$(echo "$dateMonth" | cut -c 2); fi
				dateDay=$(echo "$dateDate" | cut -d "-" -f 3);
				if [ "$dateDay" -gt 31 ]; then
					echo "Data przypomnienia: Nie możliwe jest używanie dni powyżej 31";
					exit 1; 
				else
					if [ "$dateMonth" -lt 8 ]; then
						if [ $((dateMonth % 2)) -eq 0 ]; then
							if [ "$dateMonth" -eq 2 ]; then
								if [ $((dateYear % 4)) -eq 0 ]; then
									if [ "$dateDay" -gt 29 ]; then
										echo "Data przypomnienia: Nie możliwe jest używanie dni powyżej 29";
										exit 1;
									fi	
								else
									if [ "$dateDay" -gt 28 ]; then
										echo "Data przypomnienia: Nie możliwe jest używanie dni powyżej 28";
										exit 1;
									fi
								fi
							else
								if [ "$dateDay" -gt 30 ]; then
									echo "Data przypomnienia: Nie możliwe jest używanie dni powyżej 30";
									exit 1;
								fi
							fi
						fi
					else
						if [ $((dateMonth % 2)) -eq 1 ]; then
							if [ "$dateDay" -gt 30 ]; then
								echo "Data przypomnienia: Nie możliwe jest używanie dni powyżej 30";
								exit 1;
							fi
						fi
					fi
						
				fi
				dateTime=$(echo "$date" | cut -d " " -f 2);
				if [ "$(echo "$dateTime" | cut -d ":" -f 1)" -gt 23 ]; then
					echo "Data przypomnienia: Nie możliwe jest używanie godziny powyżej 23.";
					exit 1;
				fi
				if [ "$(echo "$dateTime" | cut -d ":" -f 2)" -gt 59 ]; then
					echo "Data przypomnienia: Nie możliwe jest używanie minut powyżej 59.";
					exit 1;
				fi 	
				remindbefore=$4;
				if [[ ! $remindbefore =~ ^[0-9]{2}\:[0-9]{2}$ ]]; then
					echo "Niepoprawny format czasu przypominania";
					exit 1;
				fi
				if [ "$(echo "$remindbefore" | cut -d ":" -f 1)" -gt 24 ]; then 
					echo "Czas przypominania: Nie zalecea się używania wartości powyzej 24 godzin.";
					exit 1;
				fi
				if [ "$(echo "$remindbefore" | cut -d ":" -f 2)" -gt 59 ]; then
					echo "Czas przypominania: Nie zalecena się używania wartości powyżej 59 minut.";
					exit 1;
				fi
				if [ "$5" ]; then
					location=$5;
					echo "${id};${name};${date};${remindbefore};${location}" >> "$filename";
				else
					echo "${id};${name};${date};${remindbefore};Bd." >> "$filename";
				fi
			else
				bash "$0" help;
			fi;;
		'list') 
			i=1;
			countDbLines=$(wc -l "$filename" | awk '{printf $1}');
			while [ "$i" -le "$countDbLines" ]; do
				line=$(sed -n "${i}p" "$filename");

				id=$(echo "$line" | cut -d ";" -f 1);
				name=$(echo "$line" | cut -d ";" -f 2);
				date=$(echo "$line" | cut -d ";" -f 3);
				remindb=$(echo "$line" | cut -d ";" -f 4);

				now=$(date +%s);
				dateTimestamp=$(date -d "${date}" +%s);

				if [ "$dateTimestamp" -gt "$now" ]; then

					if [ "$((dateTimestamp - now))" -lt 604800 ]; then 
						color="\033[92m";
					fi
					
					if [ "$((dateTimestamp - now))" -lt 86400 ]; then
						color="\033[93m";
					fi

					if [ "$((dateTimestamp - now))" -gt 604800 ]; then	
						color="\033[0m";
					fi


				else
					color="\033[91m";
				fi

				if [ "$(echo "$line" | cut -d ";" -f 5)" ]; then 
					location=$(echo "$line" | cut -d ";" -f 5);
					echo -e "${color}${id}: ${name}\n\tData: ${date}\n\tPrzypomnij: ${remindb} przed\n\tLokalizacja: ${location}\n\n${endColor}";
				else
					echo -e "${color}${id}: ${name}\n\tData: ${date}\n\tPrzypomnij: ${remindb} przed\n\n${endColor}";
				fi

				i=$((i + 1))
			done;;
		'delete') id=$2;
				if [ "$id" ]; then
					if [ "$id" != "all" ]; then
						if grep -q "^${id};" "$filename"; then  
							lineAddress=$(grep -n "^${id};" "$filename" | cut -d ":" -f 1);
							sed -i "${lineAddress}d" "$filename";
						else
							echo "Przypomnienie o podanym identyfikatorze nie istnieje";
							exit 1;
						fi
					else
						echo -n > "$filename";
					fi 
				else
					bash "$0" help;
				fi;;
		'remindme') i=1;
					while 'true'; do
						countDbLines=$(wc -l "$filename" | awk '{printf $1}');
						while [ "$i" -le "$countDbLines" ]; do
							line=$(sed -n "${i}p" "$filename");
							if [ "$line" ]; then
								now=$(date +%s);
								lineDate=$(echo "$line" | cut -d ";" -f 3);
								lineDateTimestamp=$(date -d "${lineDate}" +%s);
								lineRemindb=$(echo "$line" | cut -d ";" -f 4);
								if [ "$(echo "$lineRemindb" | cut -d ":" -f 1)" = "00" ]; then
									lineRemindbM=$(echo "$lineRemindb" | cut -d ":" -f 2);
									lineRemindbSecs=$((lineRemindbM * 60));
								else
									lineRemindbH=$(echo "$lineRemindb" | cut -d ":" -f 1);
									lineRemindbM=$(echo "$lineRemindb" | cut -d ":" -f 2);
									lineRemindbSecs=$(((lineRemindbH * 3600) + (lineRemindbM * 60)));
								fi 

							
								if [ ! "$now" -gt "$lineDateTimestamp" ]; then
									if [ $((lineDateTimestamp - now)) -lt "$lineRemindbSecs" ]; then
										if [ ! "$(echo "$line" | cut -d ";" -f 6)" ]; then
											remindId=$(echo "$line" | cut -d ";" -f 1);
											remindName=$(echo "$line" | cut -d ";" -f 2);
											remindDate=$(echo "$line" | cut -d ";" -f 3)
											remindLocation=$(echo "$line" | cut -d ";" -f 5);

											/usr/bin/notify-send "${remindId}: ${remindName}" "${remindDate} | Lokalizacja: ${remindLocation}";
										fi
									fi
								fi
	
							fi
							i=$((i + 1));
						done
						sleep 60;
						i=1;
					done;;	
		'confirm') id=$2;
				if [ "$id" ]; then
					line=$(grep "^${id};" "$filename");
					if [ "$line" ]; then
						if echo "$line" | grep -q ";R$"; then 
							newline="${line};R";
							sed -i "s/${line}/${newline}/" "$filename";
						fi
					else
						echo "Przypomnienie o podanym identyfikatorze nie istnieje";
						exit 1;
					fi
				else
					bash "$0" help;
				fi;;
		'install') echo "Kopiowanie skryptu do /usr/local/bin";
				echo "Potrzebne podniesienie uprawnień";
				sudo cp "$(pwd)"/reminder.sh /usr/local/bin/reminder;
				echo "Kopiowanie pliku README.md do /usr/local/include/reminder_README.md";
				sudo cp "$(pwd)"/README.md /usr/local/include/reminder_README.md;
				echo 'if [ ! "$(ps -a | grep "reminder")" ]; then' >> ~/.bashrc;
				echo -e "\t/usr/local/bin/reminder remindme&" >> ~/.bashrc;
				echo 'fi' >> ~/.bashrc;;
			
		'help')  if [ -f /usr/local/include/reminder_README.md ]; then
				cat /usr/local/include/reminder_README.md;
			 else
				cat README.md;
			 fi;;

		*)
			bash "$0" help

		esac

else
	bash "$0" help;
fi
