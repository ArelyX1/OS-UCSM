#!/bin/bash

monitor_python_scripts() {
    trap 'return 0' INT
    
    show_banner
    echo -e "${BOLD}SCRIPTS PYTHON EN EJECUCIÓN${NC}\n"
    
    # Busca scripts de python
    echo -e "${YELLOW}Procesando...${NC}"
    all_python=$(ps aux | grep -E "python|python3" | grep -v "grep")
    
    # Filtra por hora sospechosa hmmm (00:00-06:00)
    suspicious_python=$(echo "$all_python" | grep -E "00:[0-9][0-9]:[0-9][0-9]|01:[0-9][0-9]:[0-9][0-9]|02:[0-9][0-9]:[0-9][0-9]|03:[0-9][0-9]:[0-9][0-9]|04:[0-9][0-9]:[0-9][0-9]|05:[0-9][0-9]:[0-9][0-9]")
    
    # Filtra por duración, más de 10 minutos
    long_python=$(echo "$all_python" | grep -E "[0-9]+:[0-9][0-9]:[0-9][0-9]")
    
    echo -e "${BLUE}Total scripts Python: $(echo "$all_python" | wc -l)${NC}\n"
    
    echo -e "${YELLOW}Seleccione qué scripts Python desea ver:${NC}"
    echo "1. Todos los scripts Python"
    echo "2. Scripts ejecutados en horas sospechosas (00:00-06:00)"
    echo "3. Scripts de larga duración"
    echo "4. Volver al menú principal"
    read -p "Ingrese su opción: " py_option
    
    case $py_option in
        1)
            monitor_all_python_scripts
            ;;
        2)
            monitor_suspicious_python_scripts
            ;;
        3)
            monitor_long_python_scripts
            ;;
        4)
            return 0
            ;;
        *)
            echo -e "${RED}Opción no válida${NC}"
            sleep 1
            monitor_python_scripts
            ;;
    esac
}

monitor_all_python_scripts() {
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "\n${BOLD}Todos los scripts Python:${NC}\n"
        all_python=$(ps aux | grep -E "python|python3" | grep -v "grep")
        
        if [ -n "$all_python" ]; then
            echo "$all_python" | awk '{print "PID: " $2 " | Usuario: " $1 " | Tiempo: " $9 " " $10 " | Comando: " $11 " " $12 " " $13}'
            process_pid_monitoring "python"
        else
            echo -e "${GREEN}No hay scripts Python en ejecución.${NC}"
            echo -e "\n${YELLOW}Presione 0 para volver:${NC} "
            read option
            if [ "$option" = "0" ]; then
                return 0
            fi
        fi
        
        sleep $REFRESH_RATE
    done
}

# Scripts de python sospechosos hmmm x2
monitor_suspicious_python_scripts() {
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "\n${BOLD}Scripts Python ejecutados en horas sospechosas:${NC}\n"
        suspicious_python=$(ps aux | grep -E "python|python3" | grep -v "grep" | grep -E "00:[0-9][0-9]:[0-9][0-9]|01:[0-9][0-9]:[0-9][0-9]|02:[0-9][0-9]:[0-9][0-9]|03:[0-9][0-9]:[0-9][0-9]|04:[0-9][0-9]:[0-9][0-9]|05:[0-9][0-9]:[0-9][0-9]")
        
        if [ -n "$suspicious_python" ]; then
            echo -e "${RED}¡ALERTA! Se encontraron scripts ejecutados en la madrugada:${NC}\n"
            echo "$suspicious_python" | awk '{print "PID: " $2 " | Usuario: " $1 " | Tiempo: " $9 " " $10 " | Comando: " $11 " " $12 " " $13}'
            process_pid_monitoring "python"
        else
            echo -e "${GREEN}No se encontraron scripts Python ejecutados en horas sospechosas.${NC}"
            echo -e "\n${YELLOW}Presione 0 para volver:${NC} "
            read option
            if [ "$option" = "0" ]; then
                return 0
            fi
        fi
        
        sleep $REFRESH_RATE
    done
}

monitor_long_python_scripts() {
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "\n${BOLD}Scripts Python de larga duración:${NC}\n"
        long_python=$(ps aux | grep -E "python|python3" | grep -v "grep" | grep -E "[0-9]+:[0-9][0-9]:[0-9][0-9]")
        
        if [ -n "$long_python" ]; then
            echo "$long_python" | awk '{print "PID: " $2 " | Usuario: " $1 " | Tiempo: " $9 " " $10 " | Comando: " $11 " " $12 " " $13}'
            process_pid_monitoring "python"
        else
            echo -e "${GREEN}No se encontraron scripts Python de larga duración.${NC}"
            echo -e "\n${YELLOW}Presione 0 para volver:${NC} "
            read option
            if [ "$option" = "0" ]; then
                return 0
            fi
        fi
        
        sleep $REFRESH_RATE
    done
}
