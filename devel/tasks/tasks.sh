#!/bin/bash

homedir="$HOME/.tasks";

if [ ! -d "$homedir" ]; then mkdir "$homedir"; fi

if [ ! -f "$homedir/.projects" ]; then touch "$homedir/.projects"; fi

projects="$homedir/.projects";

function lastId {

	if [ ! -f "$1" ]; then touch "$1"; lastId=0;
	else lastId=$(tail -n 1 "$1" | cut -d ";" -f 1);
	fi
}

function projectExist {

	local countProjects; local i; local line; local project; local projectExist;
	countProjects=$(wc -l "$projects" | awk '{printf $1}');
	i=1;
	while [ "$i" -le "$countProjects" ]; do
		line=$(sed -n "${i}p" "$projects");
		project=$(echo "$line" | cut -d ";" -f 2);
		if [ "$project" = "$1" ]; then projectExist=0; break;
		else projectExist=1;
		fi
		i=$((i + 1));
	done
	echo $projectExist
}

function returnProjectId {

	local countProjects; local i; local line; local project; local id;
	countProjects=$(wc -l "$projects" | awk '{printf $1}');
	i=1;
	while [ "$i" -le "$countProjects" ]; do
		line=$(sed -n "${i}p" "$projects");
		project=$(echo "$line" | cut -d ";" -f 2);
		if [ "$project" = "$1" ]; then
			id=$(echo "$line" | cut -d ";" -f 1);
			#return $id;
		else
			id=0;
			#return 0;
		fi
		i=$((i + 1));
	done 
	echo $id;

}
		

if [ "$1" ]; then

	cmd=$1;
	case $cmd in
		'createproject') name=$2;
				 if [ "$name" ]; then
					 mkdir -p "${homedir}"/"${name}"/{todo,doing,done};
					 touch "${homedir}"/"${name}"/{todo,doing,done}/tasks
					 lastId=$(tail -n 1 "$projects" | cut -d ";" -f 1);
					 if [ ! "$lastId" ]; then lastId=0; fi
					 id=$((lastId + 1));
					 dateOfCreation=$(date +%Y-%m-%d\ %H:%M);
				 	echo "${id};${name};${dateOfCreation}" >> "$projects";
				else
					bash "$0" help;
				fi;;
		'listprojects') countProjectsDB=$(wc -l "$projects" | awk '{printf $1}');
				i=1;
				while [ "$i" -le "$countProjectsDB" ]; do
					line=$(sed -n "${i}p" "$projects");
					projectId=$(echo "$line" | cut -d ";" -f 1);
					projectName=$(echo "$line" | cut -d ";" -f 2);
					projectCreationTime=$(echo "$line" | cut -d ";" -f 3);
					echo -e "${projectId}:\t${projectName}\t${projectCreationTime}";
					i=$((i + 1));
				done;;
		'deleteproject') projectName=$2;
				 if [ "$projectName" ]; then
					if [ "$(projectExist "$projectName")" -eq 0 ]; then
						
							id=$(returnProjectId "$projectName");
							lineNumber=$(grep -n "^${id};" "$projects" | cut -d ":" -f 1);
							rm -rf "${homedir:?}"/"${projectName:?}";
							sed -i "${lineNumber}d" "$projects"; 
					else
						if [ "$projectName" = "all" ]; then
							rm -rf "$homedir";
						else
							echo "Nie znaleziono projektu o takiej nazwie";
							exit 1;
						fi
					fi
				else
					bash "$0" help;
				fi;;

		'createtask') projectName=$2; 
				if [ "$projectName" ]; then
					if [ "$(projectExist "$projectName")" -eq 0 ]; then 
						tableName='todo';
						if [ ! -f "${homedir}/${projectName}/${tableName}/tasks" ]; then 
							touch "${homedir}/${projectName}/${tableName}/tasks";
							lastId=0;
						else
							lastId=$(tail -n 1 "${homedir}"/"${projectName}"/"$tableName"/tasks | cut -d ";" -f 1);
						fi
						taskName=$3;
						if [ "$taskName" ]; then
							id=$((lastId + 1));
							echo "${id};${taskName}" >> "${homedir}/${projectName}/${tableName}/tasks";
						else
							echo "Nie podano nazwy zadania";
							exit 1;
						fi
					else
						echo "Nie znaleziono projektu o takiej nazwie";
						exit 1;
					fi
				else
						bash "$0" help;
				fi;;
		
		'markas') taskPath=$2; destTable=$3;
				
				if [ ! "$taskPath" ] || [ ! "$destTable" ]; then
					bash "$0" help;
					exit 1;
				fi
	
				if [ "$(projectExist "$(echo "$taskPath" | cut -d "/" -f 1)")" -eq 0 ]; then
					if [[ $(echo "$taskPath" | cut -d "/" -f 2) =~ ^(todo|doing|done)$ ]] && \
						[[ "$destTable" =~ ^(todo|doing|done)$ ]]; then 

						basePath="${homedir}/$(echo "$taskPath" | cut -d "/" -f 1-2)/tasks";
						destPath="${homedir}/$(echo "$taskPath" | cut -d "/" -f 1)/${destTable}/tasks";

						id=$(echo "$taskPath" | cut -d "/" -f 3);
						line=$(grep "^${id};" "$basePath");
						lineNumber=$(grep -n "^${id}" "$basePath" | cut -d ":" -f 1);
						if [ "$line" ]; then
							taskName=$(echo "$line" | cut -d ";" -f 2);
							baseTable=$(echo "$taskPath" | cut -d "/" -f 2);
							case $baseTable in
								'todo') if [ "$(echo "$line" | cut -d ";" -f 3)" ]; then
										adnoteStartField=3;
									fi;;
								'doing') if [ "$(echo "$line" | cut -d ";" -f 4)" ]; then
										adnoteStartField=4;
									fi;;
								'done') if [ "$(echo "$line" | cut -d ";" -f 5)" ]; then
										adnoteStartField=5;
									fi;;
							esac
							if [ "$destTable" = "doing" ]; then
							 	startTime=$(date +%Y-%m-%d\ %H:%M);
						 		lastId "$destPath";
						 		id=$((lastId + 1));
							 	if [ "$adnoteStartField" ]; then 
									echo "${id};${taskName};${startTime};$(echo "$line" | cut -d ";" -f ${adnoteStartField}-)" >> "$destPath";
							 	else
							 		echo "${id};${taskName};${startTime}" >> "$destPath";
							 	fi
							 	sed -i "${lineNumber}d" "$basePath";
							elif [ "$destTable" = "done" ]; then
								 if [ "$baseTable" = "todo" ]; then
									startTime=$(date +%Y-%m-%d\ %H:%M);
									endTime=$startTime;
						 		else
									startTime=$(echo "$line" | cut -d ";" -f 3)
									endTime=$(date +%Y-%m-%d\ %H:%M);
						 		fi
						 		lastId "$destPath";
						 		id=$((lastId + 1));
						 		if [ "$adnoteStartField" ]; then 
									echo "${id};${taskName};${startTime};${endTime};$(echo "$line" | cut -d ";" -f ${adnoteStartField}-)" >> "$destPath";
						 		else
						 			echo "${id};${taskName};${startTime};${endTime}" >> "$destPath";
						 		fi
						 		sed -i "${lineNumber}d" "$basePath";
							else
								lastId "$destPath";
								id=$((lastId + 1));
								if [ "$adnoteStartField" ]; then
									echo "${id};${taskName};$(echo "$line" | cut -d ";" -f ${adnoteStartField}-)" >> "$destPath";
								else
									echo "${id};${taskName}" >> "$destPath";
								fi
								sed -i "${lineNumber}d" "$basePath";
							fi
							bash "$0" listtasks "$(echo "$taskPath" | cut -d "/" -f 1)";

						else
							echo "Nie znaleziono podanego zadania. Nie istnieje na podanej tablicy.";
							exit 1;
						fi
					else
						echo "Podana tablica (w ścieżce lub jako tablica docelowa) nie pasuje do schematu Tasks.";
						exit 1;
					fi
				else
					echo "Nie znaleziono podanego projektu.";
					exit 1;
				fi;;
		'listtasks') projectName=$2; 
				if [ "$projectName" ]; then
					if [ "$(projectExist "$projectName")" -eq 0 ]; then 
						endc="\033[0m";
						for tableName in 'todo' 'doing' 'done'; do
							tasksPath="${homedir}/${projectName}/${tableName}/tasks";
							tasksCount=$(wc -l "$tasksPath" | awk '{printf $1}');
							i=1;
							case $tableName in
								'todo') color="\033[91m";;
								'doing') color="\033[93m";;
								'done') color="\033[92m";;
							esac
							echo -e "${color}${tableName}: ";
							while [ "$i" -le "$tasksCount" ]; do
								line=$(sed -n "${i}p" "$tasksPath");
								id=$(echo "$line" | cut -d ";" -f 1);
								taskName=$(echo "$line" | cut -d ";" -f 2);
								case $tableName in
									'todo') echo -e "\t${color}${id}: ${taskName}${endc}";;
									'doing') startTime=$(echo "$line" | cut -d ";" -f 3);
										 echo -e "\t${color}${id}: ${taskName} | ${startTime}${endc}";;
									'done') startTime=$(echo "$line" | cut -d ";" -f 3);
										endTime=$(echo "$line" | cut -d ";" -f 4);
										echo -e "\t${color}${id}: ${taskName} | ${startTime} | ${endTime}${endc}";;
								esac
								i=$((i + 1));
							done
							echo;
						done
					else
						echo "Nie znaleziono podanego projektu.";
						exit 1;
					fi
				else
					bash "$0" help;
				fi;;
		'deletetask') taskPath=$2;
				if [ "$taskPath" ]; then
					if [ "$(projectExist "$(echo "$taskPath" | cut -d "/" -f 1)")" -eq 0 ]; then
						if [[ $(echo "$taskPath" | cut -d "/" -f 2) =~ ^(todo|doing|done)$ ]]; then

							taskId=$(echo "$taskPath" | cut -d "/" -f 3);
							tasksPath="${homedir}/$(echo "$taskPath" | cut -d "/" -f 1-2)/tasks";
							if grep -q "^${taskId};" "$tasksPath"; then
								lineNumber=$(grep -n "^${taskId};" "$tasksPath" | cut -d ":" -f 1);
								sed -i "${lineNumber}d" "$tasksPath";
							elif [ "$taskId" = "all" ]; then
								echo >> "$taskPath";
							else
								echo "Nie znaleziono podanego zadania. Nie istnieje na podanej tablicy.";
								exit 1;
							fi
						else
							echo "Podana tablica w ścieżce nie pasuje do schematu Tasks";
							exit 1;
						fi
					else
						echo "Nie znaleziono podanego projektu";
						exit 1;
					fi 
				else
					bash "$0" help;
				fi;;
		"addadnote") taskPath=$2;
				if [ "$taskPath" ]; then 
					if [ "$(projectExist "$(echo "$taskPath" | cut -d "/" -f 1)")" -eq 0 ]; then 
						if [[ $(echo "$taskPath" | cut -d "/" -f 2) =~ ^(todo|doing|done)$ ]]; then
							tasksPath="${homedir}/$(echo "$taskPath" | cut -d "/" -f 1-2)/tasks";
							if grep -q "^$(echo "$taskPath" | cut -d "/" -f 3);" "$tasksPath"; then
								line=$(grep "^$(echo "$taskPath" | cut -d "/" -f 3);" "$tasksPath");
								lineNumber=$(grep -n "^$(echo "$taskPath" | cut -d "/" -f 3);" "$tasksPath" | cut -d ":" -f 1);
								adnoteTime=$(date +%Y-%m-%d\ %H:%M);
								adnote=$3;
								if [ "$adnote" ]; then
									newline="${line};[${adnoteTime}]:'${adnote}'";
									#sed -i "s/$line/$newline/" $tasksPath;;
									sed -i "${lineNumber}i\\${newline}" "$tasksPath";
									sed -i "$((lineNumber + 1))d" "$tasksPath";
								else
									echo "Nie podano treści komentarza/adnotacji";
									exit 1;
								fi
							else
								echo "Nie znaleziono podane zadania. Nie istniej na podanej tablicy";
								exit 1;
							fi
						else
							echo "Podana tablica w ścieżce nie pasuje do schematu Tasks";
							exit 1;
						fi
						
					else
						echo "Nie znaleziono podanego projektu";
						exit 1;
					fi
				else
					bash "$0" help;
				fi;;
		"details") taskPath=$2;
				if [ "$taskPath" ]; then
					if [ "$(projectExist "$(echo "$taskPath" | cut -d "/" -f 1)")" -eq 0 ]; then
						if [[ $(echo "$taskPath" | cut -d "/" -f 2) =~ ^(todo|doing|done)$ ]]; then
							tasksPath="${homedir}/$(echo "$taskPath" | cut -d "/" -f 1-2)/tasks";
							if grep -q "^$(echo "$taskPath" | cut -d "/" -f 3);" "$tasksPath"; then 
								line=$(grep "^$(echo "$taskPath" | cut -d "/" -f 3);" "$tasksPath");
								id=$(echo "$line" | cut -d ";" -f 1);
								taskName=$(echo "$line" | cut -d ";" -f 2);
								echo -e "${id}:\t${taskName}";
								if [ "$(echo "$taskPath" | cut -d "/" -f 2)" = "doing" ]; then
									startTime=$(echo "$line" | cut -d ";" -f 3);
									echo -e "Czas rozpoczęcia:\t${startTime}";
									echo -e "\n";
									adnoteStartField=4;
								elif [ "$(echo "$taskPath" | cut -d "/" -f 2)" = "done" ]; then
									startTime=$(echo "$line" | cut -d ";" -f 3);
									echo -e "Czas rozpoczęcia:\t${startTime}"; 
									endTime=$(echo "$line" | cut -d ";" -f 4);
									echo -e "Czas zakończenia:\t${endTime}";
									echo -e "\n";
									adnoteStartField=5;
								else
									adnoteStartField=3;
								fi
								echo "Adnotacje: "
								adnotes=$(echo "$line" | cut -d ";" -f ${adnoteStartField}-);
								if [ "$adnotes" ]; then 
									countAdnotes=$(echo "$adnotes" | grep -o ";" | wc -l | awk '{printf $1}');
									countAdnotes=$((countAdnotes + 1));
									i=1;
									while [ "$i" -le "$countAdnotes" ]; do
										adnote=$(echo "$adnotes" | cut -d ";" -f "$i");
										adnoteTime=$(echo "$adnote" | cut -d ":" -f 1-2);
										adnoteTime=$(echo "$adnoteTime" | cut -d "[" -f 2 | cut -d "]" -f 1);
										adnoteContent=$(echo "$adnote" | cut -d ":" -f 3);
										echo -e "\t${adnoteTime}:\n\t\t${adnoteContent}\n";
										i=$((i + 1));
									done
								else
									echo -e "\tBrak adnotacji";
								fi
							else
								echo "Nie znaleziono podanego zadania. Nie istnieje zadanie na podanej tablicy.";
								exit 1;
							fi
						else
							echo "Podana tablica nie pasuje do schematu Tasks.";
							exit 1;
						fi
					else
						echo "Nie znaleziono podanego projektu.";
						exit 1;
					fi
				else
					bash "$0" help;
				fi;;
		'install') echo "Kopiowanie skryptu do /usr/local/bin";
				echo "Do instalacji potrzebne jest podniesienie uprawnień";
				sudo cp "$(pwd)/tasks.sh" "/usr/local/bin/tasks";
				echo "Kopiownaie pliku README.md do /usr/local/include/tasks_README.md";
				sudo cp "$(pwd)/README.md" "/usr/local/include/tasks_README.md";;	
		'help') 
			if [ -f "/usr/local/include/tasks_README.md" ]; then
				cat "/usr/local/include/tasks_README.md";
			else
				cat "README.md";
			fi;;

		*) bash "$0" help;;
	esac
else
	bash "$0" help;
fi
			
