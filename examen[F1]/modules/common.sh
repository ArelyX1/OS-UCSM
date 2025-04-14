#!/bin/bash

# ============================================================
# MÓDULO DE FUNCIONES Y VARIABLES COMUNES
# ============================================================
# Este módulo contiene definiciones y funciones
# utilizadas por todos los demás módulos del sistema de monitoreo.
# Incluye la definición de colores para la interfaz, funciones para
# mostrar banners, verificación de permisos de root y procesamiento
# de PIDs para monitoreo detallado.
#
# Funciones principales:
# - show_banner: Muestra el encabezado del programa
# - check_root: Verifica si el script se ejecuta con privilegios de admin
# - process_pid_monitoring: Maneja el procesamiento recursivo de PIDs
#
# Autor: ArelyXl + AI
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

REFRESH_RATE=2  # Tiempo en segundos entre actualizaciones

show_banner() {
    clear
    echo -e "${BLUE}=================================================================${NC}"
    echo -e "${GREEN}${BOLD}      MONITOR DE SEGURIDAD - OPCIONES DE FILTRADO      ${NC}"
    echo -e "${BLUE}=================================================================${NC}"
    echo ""
}

# Verifica si se ejecuta como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}Advertencia: Ejecutando sin privilegios de administrador.${NC}"
        echo -e "${YELLOW}Algunas funciones podrían mostrar información limitada.${NC}"
        echo -e "${YELLOW}Se recomienda ejecutar como root con 'sudo'.${NC}\n"
        sleep 2
    fi
}

process_pid_monitoring() {
    local process_type=$1
    
    while true; do
        echo -e "\n${YELLOW}Ingrese PID para más detalles (ctrl-c 2 veces o a veces 0 para volver(mejorar)):${NC} "
        read pid
        
        # PRIMERO verificar si es 0 antes de cualquier otra comprobación, eso deberia ...
        #ToDo: Una mejor manera de salir
        if [ "$pid" = "0" ]; then
            return 0
        elif [ -n "$pid" ]; then
            if ps -p $pid > /dev/null; then
                show_banner
                echo -e "\n${BOLD}Detalles del proceso $pid:${NC}"
                ps -fp $pid
                echo -e "\n${BOLD}Árbol de procesos:${NC}"
                pstree -p $pid
                
                if [ "$process_type" = "root" ]; then
                    echo -e "\n${BOLD}Archivos abiertos:${NC}"
                    lsof -p $pid 2>/dev/null | head -10
                fi
                
                echo ""
                read -p "Presione Enter para continuar..."
            else
                echo -e "${RED}El PID $pid no existe.${NC}"
                sleep 1
            fi
        fi
    done
}
