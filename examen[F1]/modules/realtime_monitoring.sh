#!/bin/bash

# ============================================================
# MÓDULO DE MONITOREO EN TIEMPO REAL
# ============================================================
# Descripción: Este módulo proporciona una vista consolidada
# en tiempo real de todos los aspectos críticos del sistema,
# actualizándose automáticamente cada 2 segundos. Muestra
# conexiones SSH, scripts Python sospechosos, conexiones de red
# y actividad del sistema en una única vista.
#
# Autor: Perplexity AI
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================

# Función para monitoreo en tiempo real
realtime_monitoring() {
    # Capturar Ctrl+C para volver al menú principal
    trap 'return 0' INT
    
    while true; do
        clear
        echo -e "${BLUE}=================================================================${NC}"
        echo -e "${GREEN}${BOLD}      MONITOR DE SEGURIDAD EN TIEMPO REAL      ${NC}"
        echo -e "${BLUE}=================================================================${NC}"
        echo -e "${YELLOW}Fecha y hora: $(date)${NC}"
        echo -e "${YELLOW}Actualización automática cada $REFRESH_RATE segundos${NC}"
        echo -e "${YELLOW}Presione Ctrl+C para volver al menú principal${NC}\n"
        
        # Mostrar carga del sistema
        echo -e "${BOLD}CARGA DEL SISTEMA:${NC}"
        uptime
        echo ""
        
        # Sección SSH
        echo -e "${BOLD}${RED}CONEXIONES SSH ACTIVAS:${NC}"
        ssh_connections=$(ps aux | grep -E "sshd:" | grep -v "grep" | grep -v "\[priv\]" | grep -v "\[net\]")
        if [ -n "$ssh_connections" ]; then
            echo "$ssh_connections" | awk '{print "PID: " $2 " | Usuario: " $1 " | Tiempo: " $9 " " $10 " | " $11 " " $12}'
            
            # Destacar conexiones recientes (últimos 5 minutos)
            recent_ssh=$(echo "$ssh_connections" | grep -E "$(date +%H:%M)|$(date --date='5 minutes ago' +%H:%M)")
            if [ -n "$recent_ssh" ]; then
                echo -e "${RED}${BOLD}¡ALERTA! Conexiones SSH recientes (últimos 5 min)${NC}"
            fi
        else
            echo -e "${GREEN}Ninguna${NC}"
        fi
        echo ""
        
        # Sección Python
        echo -e "${BOLD}${RED}SCRIPTS PYTHON SOSPECHOSOS:${NC}"
        # Buscar scripts Python en horas sospechosas
        suspicious_python=$(ps aux | grep -E "python|python3" | grep -v "grep" | grep -E "00:[0-9][0-9]:[0-9][0-9]|01:[0-9][0-9]:[0-9][0-9]|02:[0-9][0-9]:[0-9][0-9]|03:[0-9][0-9]:[0-9][0-9]|04:[0-9][0-9]:[0-9][0-9]|05:[0-9][0-9]:[0-9][0-9]")
        
        if [ -n "$suspicious_python" ]; then
            echo -e "${RED}${BOLD}¡ALERTA! Scripts ejecutados en la madrugada:${NC}"
            echo "$suspicious_python" | awk '{print "PID: " $2 " | Usuario: " $1 " | Tiempo: " $9 " " $10 " | " $11 " " $12}'
        else
            recent_python=$(ps aux | grep -E "python|python3" | grep -v "grep" | head -3)
            if [ -n "$recent_python" ]; then
                echo -e "${YELLOW}Scripts Python recientes (Top 3):${NC}"
                echo "$recent_python" | awk '{print "PID: " $2 " | Usuario: " $1 " | Tiempo: " $9 " " $10 " | " $11 " " $12}'
            else
                echo -e "${GREEN}Ninguno${NC}"
            fi
        fi
        echo ""
        
        # Sección Red
        echo -e "${BOLD}${RED}CONEXIONES DE RED ESTABLECIDAS:${NC}"
        if command -v netstat > /dev/null; then
            net_connections=$(netstat -tunapl 2>/dev/null | grep ESTABLISHED | grep -v "127.0.0.1" | head -5)
            if [ -n "$net_connections" ]; then
                echo "$net_connections" | awk '{print $4 " -> " $5 " | " $6 " | PID: " $7}'
                echo -e "${YELLOW}Mostrando primeras 5 conexiones...${NC}"
            else
                echo -e "${GREEN}Ninguna conexión externa establecida${NC}"
            fi
        elif command -v ss > /dev/null; then
            net_connections=$(ss -tunapl | grep ESTAB | grep -v "127.0.0.1" | head -5)
            if [ -n "$net_connections" ]; then
                echo "$net_connections" | awk '{print $4 " -> " $5 " | PID: " $6}'
                echo -e "${YELLOW}Mostrando primeras 5 conexiones...${NC}"
            else
                echo -e "${GREEN}Ninguna conexión externa establecida${NC}"
            fi
        else
            echo -e "${YELLOW}Herramientas de red no disponibles${NC}"
        fi
        echo ""
        
        # Sección Login
        echo -e "${BOLD}${RED}ÚLTIMOS INICIOS DE SESIÓN:${NC}"
        last -5 | grep -v "reboot" | head -3
        echo ""
        
        # Sección Procesos
        echo -e "${BOLD}${RED}PROCESOS QUE CONSUMEN MÁS CPU:${NC}"
        ps aux --sort=-%cpu | head -6 | grep -v "USER" | awk '{print "PID: " $2 " | Usuario: " $1 " | CPU: " $3 "% | MEM: " $4 "% | " $11 " " $12}'
        echo ""
        
        # Sección Procesos Root
        echo -e "${BOLD}${RED}PROCESOS ROOT NO ESTÁNDAR RECIENTES:${NC}"
        ps aux | grep "^root" | grep -v "\[" | grep -v "systemd" | grep -v "kworker" | grep -E "$(date +%H:[0-9][0-9])" | head -3
        if [ $? -ne 0 ]; then
            echo -e "${GREEN}Ninguno en la última hora${NC}"
        fi
        echo ""
        
        # Sección Alerta de Intrusión
        echo -e "${BOLD}${RED}EVALUACIÓN DE RIESGO:${NC}"
        risk_level="Bajo"
        
        # Evaluar nivel de riesgo basado en condiciones
        if [ -n "$suspicious_python" ]; then
            risk_level="Alto"
            risk_reason="Scripts Python ejecutados en horas sospechosas"
        elif [ -n "$(echo "$ssh_connections" | wc -l | grep -v "^0$")" ]; then
            if [ -n "$recent_ssh" ]; then
                risk_level="Medio-Alto"
                risk_reason="Conexiones SSH recientes"
            else
                risk_level="Medio"
                risk_reason="Conexiones SSH activas"
            fi
        elif [ -n "$(grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10 | wc -l | grep -v "^0$")" ]; then
            risk_level="Medio"
            risk_reason="Intentos fallidos de inicio de sesión recientes"
        fi
        
        if [ "$risk_level" = "Alto" ]; then
            echo -e "${RED}${BOLD}Nivel de riesgo: $risk_level${NC}"
            echo -e "${RED}Razón: $risk_reason${NC}"
        elif [ "$risk_level" = "Medio-Alto" ] || [ "$risk_level" = "Medio" ]; then
            echo -e "${YELLOW}${BOLD}Nivel de riesgo: $risk_level${NC}"
            echo -e "${YELLOW}Razón: $risk_reason${NC}"
        else
            echo -e "${GREEN}${BOLD}Nivel de riesgo: $risk_level${NC}"
            echo -e "${GREEN}No se detectaron amenazas inmediatas${NC}"
        fi
        
        # Esperar intervalo de actualización
        sleep $REFRESH_RATE
    done
}
