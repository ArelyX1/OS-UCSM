#!/bin/bash

# ============================================================
# MÓDULO DE MONITOREO DE PROCESOS DE LARGA DURACIÓN
# ============================================================
# Descripción: Este módulo identifica y analiza procesos que han
# estado ejecutándose durante períodos prolongados, lo cual puede
# indicar persistencia de malware o actividad maliciosa continua
# en el sistema.
#
# Autor: ArelyXl
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================

monitor_long_processes() {
    # Capturar Ctrl+C para volver al menú principal
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "${BOLD}PROCESOS DE LARGA DURACIÓN${NC}\n"
        
        echo -e "${YELLOW}Procesando (Ctrl+C para volver)...${NC}"
        # Buscar procesos con más de 1 hora de ejecución, ordenados por tiempo
        long_processes=$(ps -eo user,pid,ppid,etime,cmd | grep -v "ELAPSED" | sort -k4 -r | head -20)
        
        echo -e "${BLUE}Top 20 procesos de mayor duración:${NC}\n"
        echo -e "USUARIO\tPID\tPPID\tTIEMPO\tCOMANDO"
        echo "$long_processes"
        
        # Buscar procesos Python que lleven mucho tiempo ejecutándose
        long_python=$(ps -eo user,pid,etime,cmd | grep -E "python|python3" | grep -v "grep" | sort -k3 -r | head -10)
        if [ -n "$long_python" ]; then
            echo -e "\n${YELLOW}${BOLD}Scripts Python de larga duración:${NC}"
            echo -e "USUARIO\tPID\tTIEMPO\tCOMANDO"
            echo "$long_python"
        fi
        
        # Buscar procesos que se ejecutan como usuario regular pero llevan mucho tiempo
        long_user_processes=$(ps -eo user,pid,etime,cmd | grep -v "^root" | grep -v "ELAPSED" | grep -v "systemd" | sort -k3 -r | head -10)
        if [ -n "$long_user_processes" ]; then
            echo -e "\n${YELLOW}${BOLD}Procesos de usuario de larga duración:${NC}"
            echo -e "USUARIO\tPID\tTIEMPO\tCOMANDO"
            echo "$long_user_processes"
        fi
        
        echo -e "\n${YELLOW}Ingrese PID para más detalles (0 para volver):${NC} "
        read pid
        
        if [ "$pid" = "0" ]; then
            return 0
        elif [ -n "$pid" ]; then
            if ps -p $pid > /dev/null; then
                show_banner
                echo -e "\n${BOLD}Detalles del proceso $pid:${NC}"
                ps -fp $pid
                echo -e "\n${BOLD}Árbol de procesos:${NC}"
                pstree -p $pid
                
                # Mostrar información de inicio del proceso
                start_time=$(ps -o lstart= -p $pid)
                echo -e "\n${BOLD}Iniciado en:${NC} $start_time"
                
                # Mostrar archivos abiertos por el proceso
                echo -e "\n${BOLD}Archivos abiertos:${NC}"
                lsof -p $pid 2>/dev/null | head -10
                
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
