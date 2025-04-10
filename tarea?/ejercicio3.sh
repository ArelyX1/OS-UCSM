#!/bin/bash

cont=10
while [ ! $cont -lt 0 ]
do
    echo $cont
    cont=$((cont - 1))  
    sleep 1
done
echo "Fin"