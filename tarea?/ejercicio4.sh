#!/bin/bash

sum=0

echo "ingrese un numero hasta que ingrese 0"

while [ true ]
do
    read num
    if [ $num -eq 0 ]
    then
        break
    fi
    sum=$((sum + num))
done

echo "La suma es: $sum"