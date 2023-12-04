# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Include bash from Ubuntu distro.
source ~/bin/cyg-bashrc.sh

# Load the ssh-agent and default key.
source ~/bin/load-ssh-agent.sh

# set the needed environment variables for qmake and Visual Studio et cetera.
source ~/bin/set-env.sh

# My editor.
export EDITOR='joe'
