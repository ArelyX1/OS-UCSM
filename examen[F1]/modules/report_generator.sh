#!/bin/bash

# ============================================================
# MÓDULO GENERADOR DE INFORMES DE SEGURIDAD
# ============================================================
# Este módulo permite generar informes completos de
# seguridad del sistema, recopilando información de todos los demás
# módulos y guardándola en un archivo para análisis posterior o
# para mantener registros de auditoría.
#
# Autor: ArelyXl
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================

generate_report() {
    show_banner
    echo -e "${BOLD}GUARDAR INFORME COMPLETO${NC}\n"
    
    
    report_file="informe_seguridad_$(date +%Y%m%d_%H%M%S).txt"
    echo -e "${YELLOW}Generando informe completo en $report_file...${NC}\n"
    
    # Crear informe
    {
        echo "==================================================================="
        echo "                INFORME DE SEGURIDAD DEL SISTEMA"
        echo "==================================================================="
        echo "Fecha y hora: $(date)"
        echo "Hostname: $(hostname)"
        echo "Usuario: $(whoami)"
        echo "Sistema operativo: $(lsb_release -d 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME)"
        echo "Kernel: $(uname -r)"
        echo "==================================================================="
        
        echo -e "\n\n=== CONEXIONES SSH ACTIVAS ==="
        ps aux | grep -E "sshd:" | grep -v "grep" | grep -v "\[priv\]" | grep -v "\[net\]"
        
        echo -e "\n\n=== INICIOS DE SESIÓN RECIENTES ==="
        last -20
        
        if [ -f "/var/log/auth.log" ]; then
            echo -e "\n\n=== INTENTOS DE AUTENTICACIÓN SSH RECIENTES ==="
            grep -E "sshd.*(Failed|Accepted)" /var/log/auth.log | tail -20
            
            echo -e "\n\n=== IPs CON MÁS INTENTOS DE INICIO DE SESIÓN ==="
            grep -E "sshd.*from" /var/log/auth.log | grep -oE "from [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | awk '{print $2}' | sort | uniq -c | sort -nr | head -10
        fi
        
        echo -e "\n\n=== SCRIPTS PYTHON EN EJECUCIÓN ==="
        ps aux | grep -E "python|python3" | grep -v "grep"
        
        echo -e "\n\n=== SCRIPTS PYTHON EJECUTADOS EN HORAS SOSPECHOSAS ==="
        ps aux | grep -E "python|python3" | grep -v "grep" | grep -E "00:[0-9][0-9]:[0-9][0-9]|01:[0-9][0-9]:[0-9][0-9]|02:[0-9][0-9]:[0-9][0-9]|03:[0-9][0-9]:[0-9][0-9]|04:[0-9][0-9]:[0-9][0-9]|05:[0-9][0-9]:[0-9][0-9]"
        
        echo -e "\n\n=== TAREAS CRON ACTIVAS ==="
        ps aux | grep -E "CRON" | grep -v "grep"
        
        echo -e "\n\n=== TAREAS CRON PROGRAMADAS ==="
        echo "Tareas de sistema:"
        if [ -d "/etc/cron.d" ]; then
            ls -la /etc/cron.d/ | grep -v "total" | grep -v "^\."
        fi
        
        echo -e "\nTareas de usuario:"
        for user in $(cut -f1 -d: /etc/passwd); do
            crontab_content=$(crontab -l -u $user 2>/dev/null)
            if [ $? -eq 0 ] && [ -n "$crontab_content" ]; then
                echo "Usuario: $user"
                echo "$crontab_content" | grep -v "^#" | grep -v "^$"
                echo ""
            fi
        done
        
        echo -e "\n\n=== PROCESOS ROOT NO ESTÁNDAR ==="
        ps aux | grep "^root" | grep -v "\[" | grep -v "systemd" | grep -v "kworker" | grep -v "migration" | grep -v "watchdog"
        
        echo -e "\n\n=== PROCESOS DE LARGA DURACIÓN ==="
        ps -eo user,pid,ppid,etime,cmd | grep -v "ELAPSED" | sort -k4 -r | head -20
        
        echo -e "\n\n=== CONEXIONES DE RED ESTABLECIDAS ==="
        if command -v netstat > /dev/null; then
            netstat -tunapl | grep -E "ESTABLISHED|LISTEN" | grep -v "127.0.0.1"
        elif command -v ss > /dev/null; then
            ss -tunapl | grep -E "ESTAB|LISTEN" | grep -v "127.0.0.1"
        fi
        
        echo -e "\n\n=== USUARIOS ACTUALES CON SHELL ==="
        cat /etc/passwd | grep -E "bash|zsh|sh" | cut -d: -f1,7
        
        echo -e "\n\n=== ARCHIVOS MODIFICADOS RECIENTEMENTE (ÚLTIMAS 24 HORAS) ==="
        find /etc /bin /usr/bin /sbin /usr/sbin -type f -mtime -1 2>/dev/null | head -30
        
        echo -e "\n\n=== INFORMACIÓN DE MEMORIA ==="
        free -m
        
        echo -e "\n\n=== INFORMACIÓN DE DISCO ==="
        df -h
        
        echo -e "\n\n=== PROCESOS QUE MÁS RECURSOS CONSUMEN ==="
        echo "CPU:"
        ps aux --sort=-%cpu | head -11
        echo -e "\nMemoria:"
        ps aux --sort=-%mem | head -11
        
        echo -e "\n\n=== SERVICIOS DEL SISTEMA ==="
        systemctl list-units --type=service --state=running
        
        echo -e "\n\n=== INFORMACIÓN ADICIONAL ==="
        echo "Tiempo de funcionamiento del sistema:"
        uptime
        echo -e "\nHistorial de reinicios:"
        last reboot | head -5
        
        echo -e "\n\n=== FIN DEL INFORME ==="
        echo "Generado en: $(date)"
        
    } > "$report_file"
    
    # Verificar si el informe se ha generado correctamente
    if [ -f "$report_file" ]; then
        echo -e "${GREEN}Informe guardado como $report_file${NC}"
        echo -e "${YELLOW}Tamaño del archivo: $(du -h "$report_file" | cut -f1)${NC}"
        
        echo -e "\n${YELLOW}¿Desea ver un resumen del informe ahora? (s/n):${NC} "
        read view_summary
        
        if [[ "$view_summary" =~ ^[Ss]$ ]]; then
            # Mostrar un resumen con las secciones más importantes
            show_banner
            echo -e "${BOLD}RESUMEN DEL INFORME DE SEGURIDAD${NC}\n"
            
            echo -e "${YELLOW}Conexiones SSH activas:${NC}"
            grep -A 5 "CONEXIONES SSH ACTIVAS" "$report_file" | tail -n +2
            
            echo -e "\n${YELLOW}Scripts Python en horas sospechosas:${NC}"
            grep -A 10 "SCRIPTS PYTHON EJECUTADOS EN HORAS SOSPECHOSAS" "$report_file" | tail -n +2
            
            echo -e "\n${YELLOW}IPs con más intentos de login:${NC}"
            grep -A 10 "IPs CON MÁS INTENTOS DE INICIO DE SESIÓN" "$report_file" | tail -n +2
            
            echo -e "\n${YELLOW}Archivos críticos modificados recientemente:${NC}"
            grep -A 10 "ARCHIVOS MODIFICADOS RECIENTEMENTE" "$report_file" | tail -n +2
        fi
    else
        echo -e "${RED}Error al generar el informe.${NC}"
    fi
    
    echo ""
    read -p "Presione Enter para volver al menú principal..."
    return 0
}
