#!/bin/bash

while true; do
    # Find processes using more than 80% CPU and kill them
    ps -eo pid,%cpu --no-headers | awk '$2 > 80 {print $1}' | while read pid; do
        echo "Killing process with PID: $pid (CPU > 80%)"
        kill -9 "$pid"
    done
    sleep 5
done
