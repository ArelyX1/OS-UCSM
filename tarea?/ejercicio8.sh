#!/bin/bash
read -p "Enter username: " username
ps -u "$username" -o pid,cmd,%mem,%cpu --sort=-%mem
