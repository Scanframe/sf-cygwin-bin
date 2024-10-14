#!/bin/bash

# File containing agent info.
agent_file="/tmp/${NAME}-agent-cygwin"
# When the file does exists source it.
if [[ -f "${agent_file}" ]]; then
	source "${agent_file}"
fi
# When the socket is not there start a new agent.
if [[ -z "${SSH_AUTH_SOCK}" || ! -S "${SSH_AUTH_SOCK}" ]] || ! pidof ssh-agent >/dev/null ; then
	echo Starting new ssh-agent
	# Kill any existing ssh agents if any.
	killall ssh-agent 2> /dev/null
	# Write or overwrite the agent file without the last line echoing the PID.
	ssh-agent | head -n -1 > "${agent_file}"
	# Import the agent file.
	source "${agent_file}"
	# Import default key from the ~/.ssh directory.
	if [[ -f "${HOME}/.ssh/id_rsa" ]]; then
		SSH_ASKPASS_REQUIRE=force SSH_ASKPASS="ssh-askpasswd.sh" ssh-add "${HOME}/.ssh/id_rsa"
	fi 
fi


