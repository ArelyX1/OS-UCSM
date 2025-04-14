#!/bin/bash

# ============================================================
# MÓDULO DE MONITOREO DE SERVIDORES WEB
# ============================================================
# Este módulo se centra en el análisis de la actividad
# de servidores web (Apache/Nginx) para detectar posibles ataques
# web, intentos de explotación o comportamiento anómalo en las
# solicitudes HTTP.
#
# Autor: Perplexity
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================

monitor_webserver_activity() {
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "${BOLD}ACTIVIDAD DEL SERVIDOR WEB${NC}\n"
        
        echo -e "${YELLOW}Procesando (Ctrl+C para volver)...${NC}"
        
        # Detectar servidor web (Apache o Nginx)
        apache_processes=$(ps aux | grep -E "apache2|httpd" | grep -v "grep")
        nginx_processes=$(ps aux | grep "nginx" | grep -v "grep")
        
        if [ -n "$apache_processes" ]; then
            echo -e "${BLUE}Procesos de Apache:${NC}\n"
            echo "$apache_processes" | awk '{print "PID: " $2 " | Usuario: " $1 " | CPU: " $3 " | MEM: " $4 " | Tiempo: " $9 " " $10}'
            
            if [ -f "/var/log/apache2/access.log" ]; then
                echo -e "\n${BLUE}Últimas 10 solicitudes (access.log):${NC}\n"
                tail -10 /var/log/apache2/access.log
                
                # Buscar patrones de ataques comunes
                echo -e "\n${RED}${BOLD}Búsqueda de patrones de ataque en logs de Apache:${NC}"
                
                # SQL Injection
                sql_injection=$(grep -E "SELECT|UNION|INSERT|UPDATE|DELETE|DROP|'--" /var/log/apache2/access.log)
                if [ -n "$sql_injection" ]; then
                    echo -e "\n${RED}Posibles intentos de SQL Injection:${NC}"
                    echo "$sql_injection" | tail -5
                fi
                
                # LFI/Path Traversal
                path_traversal=$(grep -E "\.\./|\.\.\%2f|/etc/passwd|/etc/shadow|/proc/self" /var/log/apache2/access.log)
                if [ -n "$path_traversal" ]; then
                    echo -e "\n${RED}Posibles intentos de Path Traversal/LFI:${NC}"
                    echo "$path_traversal" | tail -5
                fi
                
                # Command Injection
                cmd_injection=$(grep -E ";|&&|\|\||%3B|%26%26|%7C%7C" /var/log/apache2/access.log)
                if [ -n "$cmd_injection" ]; then
                    echo -e "\n${RED}Posibles intentos de Command Injection:${NC}"
                    echo "$cmd_injection" | tail -5
                fi
            fi
            
            if [ -f "/var/log/apache2/error.log" ]; then
                echo -e "\n${BLUE}Últimos 10 errores (error.log):${NC}\n"
                tail -10 /var/log/apache2/error.log
            fi
            
            # Mostrar solicitudes por código de estado
            if [ -f "/var/log/apache2/access.log" ]; then
                echo -e "\n${YELLOW}Distribución de códigos de estado HTTP:${NC}"
                grep -oE " [0-9]{3} " /var/log/apache2/access.log | sort | uniq -c | sort -nr
            fi
            
        elif [ -n "$nginx_processes" ]; then
            echo -e "${BLUE}Procesos de Nginx:${NC}\n"
            echo "$nginx_processes" | awk '{print "PID: " $2 " | Usuario: " $1 " | CPU: " $3 " | MEM: " $4 " | Tiempo: " $9 " " $10}'
            
            if [ -f "/var/log/nginx/access.log" ]; then
                echo -e "\n${BLUE}Últimas 10 solicitudes (access.log):${NC}\n"
                tail -10 /var/log/nginx/access.log
                
                # Buscar patrones de ataques comunes
                echo -e "\n${RED}${BOLD}Búsqueda de patrones de ataque en logs de Nginx:${NC}"
                
                # SQL Injection
                sql_injection=$(grep -E "SELECT|UNION|INSERT|UPDATE|DELETE|DROP|'--" /var/log/nginx/access.log)
                if [ -n "$sql_injection" ]; then
                    echo -e "\n${RED}Posibles intentos de SQL Injection:${NC}"
                    echo "$sql_injection" | tail -5
                fi
                
                # LFI/Path Traversal
                path_traversal=$(grep -E "\.\./|\.\.\%2f|/etc/passwd|/etc/shadow|/proc/self" /var/log/nginx/access.log)
                if [ -n "$path_traversal" ]; then
                    echo -e "\n${RED}Posibles intentos de Path Traversal/LFI:${NC}"
                    echo "$path_traversal" | tail -5
                fi
                
                # Command Injection
                cmd_injection=$(grep -E ";|&&|\|\||%3B|%26%26|%7C%7C" /var/log/nginx/access.log)
                if [ -n "$cmd_injection" ]; then
                    echo -e "\n${RED}Posibles intentos de Command Injection:${NC}"
                    echo "$cmd_injection" | tail -5
                fi
            fi
            
            if [ -f "/var/log/nginx/error.log" ]; then
                echo -e "\n${BLUE}Últimos 10 errores (error.log):${NC}\n"
                tail -10 /var/log/nginx/error.log
            fi
            
            # Mostrar solicitudes por código de estado
            if [ -f "/var/log/nginx/access.log" ]; then
                echo -e "\n${YELLOW}Distribución de códigos de estado HTTP:${NC}"
                grep -oE " [0-9]{3} " /var/log/nginx/access.log | sort | uniq -c | sort -nr
            fi
        else
            echo -e "${YELLOW}No se detectó ningún servidor web (Apache/Nginx) en ejecución.${NC}"
        fi
        
        echo -e "\n${YELLOW}Ingrese PID para más detalles (0 para volver):${NC} "
        read pid
        
        if [ "$pid" = "0" ]; then
            return 0
        elif [ -n "$pid" ]; then
            if ps -p $pid > /dev/null; then
                show_banner
                echo -e "\n${BOLD}Detalles del proceso web $pid:${NC}"
                ps -fp $pid
                
                echo -e "\n${BOLD}Archivos abiertos por el proceso:${NC}"
                lsof -p $pid 2>/dev/null | head -10
                
                echo -e "\n${BOLD}Conexiones de red del proceso:${NC}"
                if command -v netstat > /dev/null; then
                    netstat -tunapl | grep $pid
                elif command -v ss > /dev/null; then
                    ss -tunapl | grep "pid=$pid"
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
