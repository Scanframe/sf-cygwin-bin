#!/bin/bash

ssh $* -R 6010:localhost:6000 -t "DISPLAY=:10.0 KDE_FULL_SESSION=true XCURSOR_SIZE=16 /bin/bash"

