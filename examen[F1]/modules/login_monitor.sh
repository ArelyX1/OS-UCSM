#!/bin/bash

# ============================================================
# MÓDULO DE MONITOREO DE INICIOS DE SESIÓN
# ============================================================
# Este módulo analiza el historial de inicios de sesión
# en el sistema, tanto exitosos como fallidos, para detectar posibles
# intentos de intrusión mediante ataques de fuerza bruta o accesos
# no autorizados.
#
# Autor: ArelyXl
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================

monitor_login_history() {
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "${BOLD}HISTORIAL DE INICIOS DE SESIÓN${NC}\n"
        
        echo -e "${YELLOW}Procesando (Ctrl+C para volver)...${NC}"
        
        echo -e "${BLUE}Últimos 10 inicios de sesión:${NC}\n"
        last -10
        
        echo -e "\n${BLUE}Inicios de sesión SSH exitosos recientes:${NC}\n"
        if [ -f "/var/log/auth.log" ]; then
            grep "Accepted" /var/log/auth.log | tail -10
        else
            journalctl -u ssh --no-pager | grep "Accepted" | tail -10
        fi
        
        # intentos fallidos
        echo -e "\n${BLUE}Intentos de inicio de sesión fallidos recientes:${NC}\n"
        if [ -f "/var/log/auth.log" ]; then
            grep "Failed password" /var/log/auth.log | tail -10
        else
            journalctl -u ssh --no-pager | grep "Failed password" | tail -10
        fi
        
        # posibles ataques de fuerza bruta
        echo -e "\n${RED}${BOLD}Análisis de intentos de autenticación SSH:${NC}"
        if [ -f "/var/log/auth.log" ]; then
            echo -e "\n${YELLOW}Top 10 IPs con más intentos de inicio de sesión:${NC}"
            grep -E "sshd.*from" /var/log/auth.log | grep -oE "from [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | awk '{print $2}' | sort | uniq -c | sort -nr | head -10
            
            echo -e "\n${YELLOW}Top 10 usuarios utilizados en intentos SSH:${NC}"
            grep -E "sshd.*user" /var/log/auth.log | grep -oE "user [a-zA-Z0-9_-]+" | awk '{print $2}' | sort | uniq -c | sort -nr | head -10
            
            # posibles ataques de fuerza bruta (muchos intentos desde la misma IP) oh no 
            # aunq no se si esto sea necesario, creo que es ultimo que haria alguien para entrar al sistema XD
            bruteforce=$(grep "Failed password" /var/log/auth.log | grep -oE "from [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | awk '{print $2}' | sort | uniq -c | sort -nr | head -5)
            
            if [ -n "$bruteforce" ]; then
                high_attempts=$(echo "$bruteforce" | awk '$1 > 5 {print}')
                if [ -n "$high_attempts" ]; then
                    echo -e "\n${RED}${BOLD}¡ALERTA! Posible ataque de fuerza bruta detectado:${NC}"
                    echo "$high_attempts"
                fi
            fi
        else
            echo -e "${YELLOW}No se encontró el archivo auth.log${NC}"
        fi
        
        # Usuarios conectados
        echo -e "\n${BLUE}Usuarios actualmente conectados:${NC}\n"
        who
        
        # Sesiones SSH activas
        echo -e "\n${BLUE}Sesiones SSH activas:${NC}\n"
        ps aux | grep -E "sshd:" | grep -v "grep" | grep -v "\[priv\]" | grep -v "\[net\]" || echo "Ninguna sesión SSH activa"
        
        echo -e "\n${YELLOW}Presione 0 para volver al menú principal:${NC} "
        read option
        if [ "$option" = "0" ]; then
            return 0
        fi
        
        sleep $REFRESH_RATE
    done
}
