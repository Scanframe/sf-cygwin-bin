#!/bin/bash 
script="$(cygpath -w "$1")"
shift 1
powershell  -ExecutionPolicy ByPass -File ${script} "$@"