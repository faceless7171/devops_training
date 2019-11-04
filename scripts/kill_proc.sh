#!/bin/bash

set -e

PROCESS_NAME=${1:?"Please specify process name"}

if [ -x $(pgrep -xo "$PROCESS_NAME") ]; then
    echo "There is no process with this name."
    exit 1
fi

echo "Processes to be killed:"
pstree -p $(pgrep -xo "$PROCESS_NAME")

pkill -TERM -xo "$PROCESS_NAME" && echo "Processes killed." || echo "Failed to kill processes"; exit 1
