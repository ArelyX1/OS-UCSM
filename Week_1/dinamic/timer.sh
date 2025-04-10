#!/bin/bash

# Ejecutar el script Python en segundo plano
# /usr/bin/python3.13 /home/arelyxl/Downloads/VsCode/Operating_system/Shell/Week_1/dinamic/hora.py &
#sleep 0.3


PYTHON_PID=$(pgrep -n -f "/home/arelyxl/Downloads/VsCode/Operating_system/Shell/Week_1/dinamic/hora.py")

if [ -z "$PYTHON_PID" ]; then
    echo "Error: No se pudo obtener el PID del proceso"
    exit 1
fi

# Método alternativo 2: Usar ps + grep (descomentar si pgrep falla)
# PYTHON_PID=$(ps aux | grep "[h]ora.py" | awk '{print $2}')

now=$(date +%s)
target=$(date -d "6:14" +%s)

if [ $now -ge $target ]; then
    target=$(date -d "tomorrow 09:30" +%s)
fi

while true; do
    now=$(date +%s)
    diff=$((target - now))

    if [ $diff -le 0 ]; then
        break
    fi
    
    sleep 1
done

# Opción 1: Terminar por PID específico
kill $PYTHON_PID

echo -e "\nEs hora de matar a POU"