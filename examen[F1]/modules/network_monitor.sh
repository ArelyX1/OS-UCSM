#!/bin/bash

# ============================================================
# MÓDULO DE MONITOREO DE CONEXIONES DE RED
# ============================================================
# Este módulo analiza las conexiones de red activas
# en el sistema, con énfasis en detectar conexiones establecidas
# con sistemas externos que podrían indicar comunicación con
# servidores de comando y control o exfiltración de datos.
#
# Autor: Perplexity
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================

# Función para monitorear conexiones de red
monitor_network_connections() {
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "${BOLD}CONEXIONES DE RED ACTIVAS${NC}\n"
        
        echo -e "${YELLOW}Procesando (Ctrl+C para volver)...${NC}"
        
        # Determinar qué herramienta usar
        if command -v netstat > /dev/null; then
            TOOL="netstat"
            echo -e "${BLUE}Usando netstat para análisis de red${NC}\n"
            
            # Conexiones establecidas con sistemas externos
            echo -e "${BOLD}Conexiones TCP establecidas con sistemas externos:${NC}"
            netstat -tunapl | grep ESTABLISHED | grep -v "127.0.0.1" | awk '{print $4, $5, $6, $7}' | column -t
            
            # Puertos en escucha
            echo -e "\n${BOLD}Puertos en escucha (posibles servicios):${NC}"
            netstat -tunapl | grep LISTEN | awk '{print $4, $6, $7}' | column -t
            
            # Destacar puertos no estándar
            suspicious_ports=$(netstat -tunapl | grep -E "LISTEN|ESTABLISHED" | grep -E ":4444|:1337|:31337|:6666|:6667|:6668|:6669|:6697")
            if [ -n "$suspicious_ports" ]; then
                echo -e "\n${RED}${BOLD}¡ALERTA! Puertos sospechosos detectados:${NC}"
                echo "$suspicious_ports" | awk '{print $4, $5, $6, $7}' | column -t
            fi
            
        elif command -v ss > /dev/null; then
            TOOL="ss"
            echo -e "${BLUE}Usando ss para análisis de red${NC}\n"
            
            # Conexiones establecidas con sistemas externos
            echo -e "${BOLD}Conexiones TCP establecidas con sistemas externos:${NC}"
            ss -tunapl | grep ESTAB | grep -v "127.0.0.1" | awk '{print $4, $5, $6}' | column -t
            
            # Puertos en escucha
            echo -e "\n${BOLD}Puertos en escucha (posibles servicios):${NC}"
            ss -tunapl | grep LISTEN | awk '{print $4, $5, $6}' | column -t
            
            # Destacar puertos no estándar
            suspicious_ports=$(ss -tunapl | grep -E "LISTEN|ESTAB" | grep -E ":4444|:1337|:31337|:6666|:6667|:6668|:6669|:6697")
            if [ -n "$suspicious_ports" ]; then
                echo -e "\n${RED}${BOLD}¡ALERTA! Puertos sospechosos detectados:${NC}"
                echo "$suspicious_ports" | awk '{print $4, $5, $6}' | column -t
            fi
        else
            echo -e "${RED}No se encontraron herramientas netstat o ss para mostrar conexiones.${NC}"
            TOOL="none"
        fi
        
        if [ "$TOOL" != "none" ]; then
            echo -e "\n${BOLD}Procesos con conexiones de red activas:${NC}"
            if [ "$TOOL" = "netstat" ]; then
                network_processes=$(netstat -tunapl | grep -E "ESTABLISHED|LISTEN" | grep -v "127.0.0.1" | awk '{print $7}' | cut -d "/" -f 1 | sort -u)
            else
                network_processes=$(ss -tunapl | grep -E "ESTAB|LISTEN" | grep -v "127.0.0.1" | awk '{print $7}' | cut -d "," -f 2 | cut -d "=" -f 2 | sort -u)
            fi
            
            if [ -n "$network_processes" ]; then
                for pid in $network_processes; do
                    if [ "$pid" != "-" ] && [ "$pid" != "users" ]; then
                        ps -fp $pid 2>/dev/null
                    fi
                done
            else
                echo -e "${GREEN}No se encontraron procesos con conexiones de red activas.${NC}"
            fi
        fi
        
        echo -e "\n${YELLOW}Ingrese PID para más detalles (0 para volver):${NC} "
        read pid
        
        if [ "$pid" = "0" ]; then
            return 0
        elif [ -n "$pid" ]; then
            if ps -p $pid > /dev/null; then
                show_banner
                echo -e "\n${BOLD}Detalles del proceso $pid con conexiones de red:${NC}"
                ps -fp $pid
                
                echo -e "\n${BOLD}Conexiones de red específicas de este proceso:${NC}"
                if [ "$TOOL" = "netstat" ]; then
                    netstat -tunapl | grep $pid
                else
                    ss -tunapl | grep "pid=$pid"
                fi
                
                echo -e "\n${BOLD}Archivos abiertos por el proceso:${NC}"
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
