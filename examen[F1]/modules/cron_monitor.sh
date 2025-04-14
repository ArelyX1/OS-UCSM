#!/bin/bash

# ============================================================
# MÓDULO DE MONITOREO DE TAREAS CRON
# ============================================================
# Este módulo se centra en la detección y análisis
# de tareas programadas (CRON) que podrían estar ejecutando código
# malicioso en el sistema. Examina tanto las tareas CRON activas
# como las programadas en el sistema de archivos.
#
# Autor: ArelyXl
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================

monitor_cron_tasks() {
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "${BOLD}TAREAS CRON${NC}\n"
        
        echo -e "${YELLOW}Procesando (Ctrl+C para volver)...${NC}"
        cron_active=$(ps aux | grep -E "CRON" | grep -v "grep")
        
        echo -e "${BLUE}Tareas CRON activas: $(echo "$cron_active" | wc -l)${NC}\n"
        
        if [ -n "$cron_active" ]; then
            echo "$cron_active" | awk '{print "PID: " $2 " | Usuario: " $1 " | Tiempo: " $9 " " $10 " | Comando: " $11 " " $12}'
            
            # tareas CRON ejecutadas a horas inusuales
            unusual_cron=$(echo "$cron_active" | grep -E "00:[0-9][0-9]:[0-9][0-9]|01:[0-9][0-9]:[0-9][0-9]|02:[0-9][0-9]:[0-9][0-9]|03:[0-9][0-9]:[0-9][0-9]|04:[0-9][0-9]:[0-9][0-9]|05:[0-9][0-9]:[0-9][0-9]")
            
            if [ -n "$unusual_cron" ]; then
                echo -e "\n${RED}${BOLD}¡ALERTA! Tareas CRON ejecutadas en horas inusuales:${NC}"
                echo "$unusual_cron" | awk '{print "PID: " $2 " | Usuario: " $1 " | Tiempo: " $9 " " $10 " | Comando: " $11 " " $12}'
            fi
        else
            echo -e "${GREEN}No hay tareas CRON activas en este momento.${NC}"
        fi
        
        echo -e "\n${YELLOW}Tareas CRON programadas:${NC}"
        
        echo -e "\n${BOLD}Tareas del sistema:${NC}"
        if [ -d "/etc/cron.d" ]; then
            ls -la /etc/cron.d/ | grep -v "total" | grep -v "^\."
        fi
        
        echo -e "\n${BOLD}Tareas de usuario:${NC}"
        user_crontabs=0
        for user in $(cut -f1 -d: /etc/passwd); do
            crontab -l -u $user 2>/dev/null | grep -v "^#" | grep -v "^$"
            if [ $? -eq 0 ]; then
                echo -e "Usuario: ${YELLOW}$user${NC}"
                user_crontabs=$((user_crontabs+1))
            fi
        done
        
        if [ $user_crontabs -eq 0 ]; then
            echo -e "${GREEN}No se encontraron tareas CRON de usuarios.${NC}"
        fi
        
        echo -e "\n${YELLOW}Ingrese PID para más detalles (0 para volver):${NC} "
        read pid
        
        if [ "$pid" = "0" ]; then
            return 0
        elif [ -n "$pid" ]; then
            if ps -p $pid > /dev/null; then
                show_banner
                echo -e "\n${BOLD}Detalles del proceso CRON $pid:${NC}"
                ps -fp $pid
                echo -e "\n${BOLD}Árbol de procesos:${NC}"
                pstree -p $pid
                
                # Mostrar los comandos hijos del proceso CRON
                child_pids=$(pgrep -P $pid)
                if [ -n "$child_pids" ]; then
                    echo -e "\n${BOLD}Procesos hijos del CRON:${NC}"
                    for child in $child_pids; do
                        ps -fp $child
                    done
                fi
                
                echo ""
                read -p "Presione Enter para continuar..."
            else
                echo -e "${RED}El PID $pid no existe.${NC}"
                sleep 1
            fi
        fi
        
        sleep $REFRESH_RATE
    done
}
