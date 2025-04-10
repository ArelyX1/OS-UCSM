#!/bin/bash
while true; do
    clear
    ps aux | awk '{print $2, $4, $11}' | sort -k2r | head -n 15
    sleep 3
done
