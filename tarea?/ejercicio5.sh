#!/bin/bash

while [ true ]
do
    clear
    ps -e  -o pid,uname,cmd,%mem,%cpu --sort=-%cpu | head -15
    sleep 1
done