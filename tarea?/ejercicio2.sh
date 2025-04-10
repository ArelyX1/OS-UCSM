#!/bin/bash

while [ ! -e "hw.txt" ]
do
    echo "Esperando a que se cree el archivo hw.txt..."
    sleep 0.4
done

echo "El archivo hw.txt ha sido creado."