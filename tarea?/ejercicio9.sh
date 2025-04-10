#!/bin/bash

# Show current processes
echo "Current processes:"
ps -e -o pid,cmd,%mem,%cpu --sort=-%mem | head -20

# Prompt user for the process name
read -p "Enter the process name to monitor: " process_name

# Monitor the specified process
while true; do
    clear
    echo "Monitoring process: $process_name"
    ps -C "$process_name" -o pid,%cpu,%mem --no-headers || echo "$process_name is not running"
    sleep 5
done
