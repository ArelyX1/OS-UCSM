#!/bin/bash

# ============================================================
# MONITOR DE SEGURIDAD PARA UBUNTU 24.04
# ============================================================
# Script principal que integra todos los módulos de monitoreo
# de seguridad. Presenta un menú interactivo que permite al usuario
# seleccionar diferentes opciones para analizar registros del sistema,
# detectar conexiones remotas sospechosas y monitorear procesos.
#
# Autor: ArelyXl y apoyo moral de Perplexity
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================

# Determinar la ubicación del script automáticamente
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR="$SCRIPT_DIR/modules"

# Verificar que el directorio de módulos existe
if [ ! -d "$MODULE_DIR" ]; then
    echo "Error: No se encontró el directorio de módulos en $MODULE_DIR"
    echo "Por favor ejecute el script de instalación primero."
    exit 1
fi

# Cargar módulos (con verificación de existencia)
echo "Cargando módulos desde $MODULE_DIR..."

# Definir una función para cargar módulos de forma segura
load_module() {
    if [ -f "$MODULE_DIR/$1" ]; then
        source "$MODULE_DIR/$1"
        echo "✓ Módulo $1 cargado correctamente"
    else
        echo "✗ Error: No se encontró el módulo $1"
        missing_modules=true
    fi
}

# Variable para rastrear si faltan módulos
missing_modules=false

# Cargar cada módulo individualmente
load_module "common.sh"
load_module "ssh_monitor.sh"
load_module "python_monitor.sh"
load_module "cron_monitor.sh"
load_module "root_monitor.sh"
load_module "longproc_monitor.sh"
load_module "network_monitor.sh"
load_module "login_monitor.sh"
load_module "webserver_monitor.sh"
load_module "report_generator.sh"
load_module "realtime_monitoring.sh"


# Verificar si faltó algún módulo
if [ "$missing_modules" = true ]; then
    echo "Algunos módulos no pudieron ser cargados. El sistema puede no funcionar correctamente."
    echo "Ejecute el script de instalación nuevamente: ./install.sh"
    read -p "¿Desea continuar de todos modos? (s/n): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi

# Definir la función de monitoreo en tiempo real (para el caso de que falte el módulo)
if ! command -v realtime_monitoring &> /dev/null; then
    realtime_monitoring() {
        echo "La función de monitoreo en tiempo real no está disponible."
        echo "Falta el módulo correspondiente."
        read -p "Presione Enter para volver al menú principal..."
        return 0
    }
fi

# Función principal - Menú de opciones
main_menu() {
    show_banner
    echo -e "${YELLOW}SELECCIONE UNA OPCIÓN DE FILTRADO:${NC}"
    echo ""
    echo "1. Conexiones SSH activas (posibles intrusiones remotas)"
    echo "2. Scripts Python en ejecución (filtrados por hora sospechosa)"
    echo "3. Tareas CRON programadas"
    echo "4. Procesos con privilegios de root no estándar"
    echo "5. Procesos de larga duración (posible persistencia)"
    echo "6. Conexiones de red establecidas"
    echo "7. Últimos inicios de sesión"
    echo "8. Actividad del servidor web (Apache/Nginx)"
    echo "9. Monitoreo en tiempo real (actualización cada 2 segundos)"
    echo "10. Guardar informe completo a archivo"
    echo "0. Salir"
    echo ""
    read -p "Ingrese su opción: " option
    
    case $option in
        1) monitor_ssh_connections; main_menu ;;
        2) monitor_python_scripts; main_menu ;;
        3) monitor_cron_tasks; main_menu ;;
        4) monitor_root_processes; main_menu ;;
        5) monitor_long_processes; main_menu ;;
        6) monitor_network_connections; main_menu ;;
        7) monitor_login_history; main_menu ;;
        8) monitor_webserver_activity; main_menu ;;
        9) realtime_monitoring; main_menu ;;
        10) generate_report; main_menu ;;
        0) echo -e "${GREEN}Saliendo...${NC}"; exit 0 ;;
        *) echo -e "${RED}Opción no válida${NC}"; sleep 1; main_menu ;;
    esac
}

# Verificar si los colores están definidos (caso en que common.sh no se cargó)
if [ -z "$RED" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
fi

# Definir show_banner como fallback si no existe
if ! command -v show_banner &> /dev/null; then
    show_banner() {
        clear
        echo -e "${BLUE}=================================================================${NC}"
        echo -e "${GREEN}${BOLD}      MONITOR DE SEGURIDAD - OPCIONES DE FILTRADO      ${NC}"
        echo -e "${BLUE}=================================================================${NC}"
        echo ""
    }
fi

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Advertencia: Ejecutando sin privilegios de administrador.${NC}"
    echo -e "${YELLOW}Algunas funciones podrían mostrar información limitada.${NC}"
    echo -e "${YELLOW}Se recomienda ejecutar como root con 'sudo'.${NC}\n"
    sleep 2
fi

# Iniciar el programa
main_menu
