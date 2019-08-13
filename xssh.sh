#!/bin/bash

ssh $* -R 6010:localhost:6000 -t "DISPLAY=:10.0 /bin/bash"

