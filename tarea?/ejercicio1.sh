#!/bin/bash

cont=0

while [ $cont -lt 10 ]
do
    echo $cont
    cont=$((cont + 1))  
    sleep 1
done
echo "Fin"