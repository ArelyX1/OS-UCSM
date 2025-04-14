#!/bin/bash

# ============================================================
# MÓDULO DE MONITOREO DE PROCESOS ROOT
# ============================================================
# Este módulo se especializa en la detección y análisis
# de procesos que se ejecutan con privilegios de administrador (root)
# pero que no son procesos estándar del sistema. Estos procesos tienen
# mayor potencial para comprometer la seguridad del sistema.
#
# Autor: ArelyXl
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================

monitor_root_processes() {
    trap 'return 0' INT
    
    while true; do
        show_banner
        echo -e "${BOLD}PROCESOS ROOT NO ESTÁNDAR${NC}\n"
        
        echo -e "${YELLOW}Procesando (Ctrl+C para volver)...${NC}"
        # Excluir procesos del sistema comunes para reducir ruido
        root_processes=$(ps aux | grep "^root" | grep -v "\[" | grep -v "systemd" | grep -v "kworker" | 
                       grep -v "migration" | grep -v "watchdog" | grep -v "irq" | grep -v "sshd:" | 
                       grep -v "rsyslogd" | grep -v "dbus-daemon" | grep -v "networkd" | grep -v "udevd" |
                       grep -v "apache2" | grep -v "nginx" | grep -v "mysqld" | grep -v "named" |
                       grep -v "smbd" | grep -v "cupsd" | grep -v "snapd" | grep -v "polkitd")
        
        echo -e "${BLUE}Total procesos root no estándar: $(echo "$root_processes" | wc -l)${NC}\n"
        
        if [ -n "$root_processes" ]; then
            echo "$root_processes" | awk '{print "PID: " $2 " | CPU: " $3 " | MEM: " $4 " | Tiempo: " $9 " " $10 " | Comando: " $11 " " $12 " " $13 " " $14}'
            
            # Destacar procesos sospechosos (usando puertos no estándar o ejecutados recientemente)
            suspicious_root=$(echo "$root_processes" | grep -E "nc |netcat|wget|curl|bash.*-c|sh.*-c|python.*-c|base64|/dev/tcp|/dev/udp")
            if [ -n "$suspicious_root" ]; then
                echo -e "\n${RED}${BOLD}¡ALERTA! Procesos root potencialmente sospechosos:${NC}"
                echo "$suspicious_root" | awk '{print "PID: " $2 " | Tiempo: " $9 " " $10 " | Comando: " $11 " " $12 " " $13 " " $14}'
            fi
            
            process_pid_monitoring "root"
        else
            echo -e "${GREEN}No se encontraron procesos root no estándar.${NC}"
            echo -e "\n${YELLOW}Presione 0 para volver al menú principal:${NC} "
            read option
            if [ "$option" = "0" ]; then
                return 0
            fi
        fi
        
        sleep $REFRESH_RATE
    done
}
