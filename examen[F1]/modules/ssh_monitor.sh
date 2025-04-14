#!/bin/bash

monitor_ssh_connections() {
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "${BOLD}CONEXIONES SSH ACTIVAS${NC}\n"
        
        # Encuentra conexiones SSH activas
        echo -e "${YELLOW}Actualizando datos (Ctrl+C para volver al menú principal)...${NC}"
        ssh_connections=$(ps aux | grep -E "sshd:" | grep -v "grep" | grep -v "\[priv\]" | grep -v "\[net\]")
        
        if [ -n "$ssh_connections" ]; then
            echo -e "${RED}¡ALERTA! Se encontraron $(echo "$ssh_connections" | wc -l) conexiones SSH activas:${NC}\n"
            echo "$ssh_connections" | awk '{print "PID: " $2 " | Usuario: " $1 " | Tiempo: " $9 " " $10 " | Comando: " $11 " " $12}'
            
            if [ -f "/var/log/auth.log" ]; then
                echo -e "\n${YELLOW}Últimos intentos de inicio de sesión SSH (auth.log):${NC}"
                grep -E "sshd.*Failed|sshd.*Accepted" /var/log/auth.log | tail -5
            fi
            
            process_pid_monitoring "ssh"
        else
            echo -e "${GREEN}No se encontraron conexiones SSH activas en este momento.${NC}"
            echo -e "\n${YELLOW}Presione 0 para volver al menú principal:${NC} "
            read option
            if [ "$option" = "0" ]; then
                return 0
            fi
        fi
        #hola
        sleep $REFRESH_RATE
    done
}
