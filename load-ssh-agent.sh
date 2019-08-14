#!/bin/bash

# Load ssh stuff.
if [[ -z "${SSH_AGENT_PID}" ]] ; then

	# Kill any existing ssh agents.
	killall ssh-agent
	
        # Load ssh-agent setting the needed env variable.
        eval $(ssh-agent) > /dev/null

        # Load default ssh key into agent.
        ssh-add
        
        
fi

