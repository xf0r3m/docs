#!/bin/bash

projects="/home/xf0r3m/.tasks/projects";

function testowanie {

	if [ "$projects" ]; then local projectsExist=56;
	else local projectsExist=57;
	fi
	#echo $projects;
	return $projectsExist;

}

testowanie;
echo $?;
