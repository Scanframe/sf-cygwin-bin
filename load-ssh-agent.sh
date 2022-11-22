#!/bin/bash

# Load ssh stuff only when mintty console and SSH_AGENT_PID has not been set.
if [[ "${TERM_PROGRAM}" == "mintty" && -z "${SSH_AGENT_PID}" ]] ; then

	# Kill any existing ssh agents.
	killall ssh-agent > /dev/null
	
	# Load ssh-agent setting the needed env variable.
	eval $(ssh-agent) > /dev/null

	# Load default ssh key into agent.
	ssh-add
	
	echo 'Hint use from CLI: set CHERE_INVOKING=1 & C:\cygwin64\bin\bash.exe --login'

# Othewise try to get the enviroment vars from the running agent.
else
	
	# Get the running ssh-agent pid.
	if CUR_PID="$(pidof "ssh-agent"  /dev/null)" ; then
		# Export it to the environment.
		export SSH_AGENT_PID="${CUR_PID}"
		# Also the socket which has a pid -1 name in the temp dir.
		export SSH_AUTH_SOCK="$(ls "${TEMP}/ssh-"*"/agent.$((${CUR_PID}-1))")"
		# echo "Found ssh-agent at pid '${CUR_PID}' and socket  '${SSH_AUTH_SOCK}'."
	fi
        
fi

