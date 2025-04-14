#!/bin/bash

# ============================================================
# INSTALADOR DEL SISTEMA DE MONITOREO DE SEGURIDAD
# ============================================================
# Descripción: Este script facilita la instalación del sistema
# completo de monitoreo de seguridad, creando la estructura de
# directorios necesaria, configurando los permisos adecuados e
# instalando las dependencias requeridas por el sistema.
#
# Autor: Perplexity AI
# Fecha: Abril 2025
# Versión: 1.0
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${BLUE}=================================================================${NC}"
echo -e "${GREEN}${BOLD}   INSTALACIÓN DEL MONITOR DE SEGURIDAD PARA UBUNTU 24.04   ${NC}"
echo -e "${BLUE}=================================================================${NC}"
echo ""

SOURCE_DIR="$(pwd)"

echo -e "${YELLOW}Ingrese la ruta completa donde desea instalar el monitor de seguridad:${NC}"
read -p "> " INSTALL_DIR

# Verificar si la ruta ingresada es válida
if [ -z "$INSTALL_DIR" ]; then
    echo -e "${RED}Error: No se ingresó ninguna ruta. Abortando instalación.${NC}"
    exit 1
fi

INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}El directorio $INSTALL_DIR no existe. ¿Desea crearlo? (s/n):${NC}"
    read -p "> " create_dir
    
    if [[ "$create_dir" =~ ^[Ss]$ ]]; then
        mkdir -p "$INSTALL_DIR" || { echo -e "${RED}Error: No se pudo crear el directorio. Abortando instalación.${NC}"; exit 1; }
        echo -e "${GREEN}Directorio creado exitosamente.${NC}"
    else
        echo -e "${RED}Instalación cancelada por el usuario.${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}Instalando el monitor de seguridad en: $INSTALL_DIR${NC}"

# Crear estructura de directorios
if [ ! -d "$INSTALL_DIR/modules" ]; then
    echo -e "${BLUE}Creando directorio de módulos...${NC}"
    mkdir -p "$INSTALL_DIR/modules"
fi

# Lista de módulos a crear
modules=(
    "common.sh"
    "ssh_monitor.sh"
    "python_monitor.sh"
    "cron_monitor.sh"
    "root_monitor.sh"
    "longproc_monitor.sh"
    "network_monitor.sh"
    "login_monitor.sh"
    "webserver_monitor.sh"
    "report_generator.sh"
    "realtime_monitoring.sh"
)

# Crear o copiar archivos de módulos
echo -e "\n${BLUE}Configurando módulos...${NC}"
for module in "${modules[@]}"; do
    # Verificar si el módulo existe en el directorio actual o en su subdirectorio /modules
    if [ -f "$SOURCE_DIR/$module" ]; then
        echo -e "${GREEN}Copiando $module desde el directorio actual...${NC}"
        cp "$SOURCE_DIR/$module" "$INSTALL_DIR/modules/$module"
    elif [ -f "$SOURCE_DIR/modules/$module" ]; then
        echo -e "${GREEN}Copiando $module desde ./modules/...${NC}"
        cp "$SOURCE_DIR/modules/$module" "$INSTALL_DIR/modules/$module"
    else
        echo -e "${YELLOW}No se encontró $module para copiar. Creando archivo vacío...${NC}"
        touch "$INSTALL_DIR/modules/$module"
    fi
    chmod +x "$INSTALL_DIR/modules/$module"
done

# Crear o copiar archivo principal
echo -e "${GREEN}Configurando main.sh...${NC}"
if [ -f "$SOURCE_DIR/main.sh" ]; then
    echo -e "${GREEN}Copiando main.sh desde el directorio actual...${NC}"
    cp "$SOURCE_DIR/main.sh" "$INSTALL_DIR/main.sh"
else
    echo -e "${YELLOW}No se encontró main.sh para copiar. Creando archivo vacío...${NC}"
    touch "$INSTALL_DIR/main.sh"
fi
chmod +x "$INSTALL_DIR/main.sh"

echo -e "\n${BLUE}Instalando dependencias necesarias...${NC}"
sudo apt-get update
sudo apt-get install -y pstree lsof net-tools

# Crear un script de acceso directo (opcional), en plan lo mismo que ira a main.sh
if [ "$INSTALL_DIR" != "$SOURCE_DIR" ]; then
    echo -e "\n${YELLOW}¿Desea crear un acceso directo en el directorio actual? (s/n):${NC}"
    read -p "> " create_shortcut
    
    if [[ "$create_shortcut" =~ ^[Ss]$ ]]; then
        echo -e "${GREEN}Creando acceso directo...${NC}"
        echo '#!/bin/bash' > "$SOURCE_DIR/security_monitor.sh"
        echo "cd $INSTALL_DIR && sudo ./main.sh" >> "$SOURCE_DIR/security_monitor.sh"
        chmod +x "$SOURCE_DIR/security_monitor.sh"
        echo -e "${GREEN}Acceso directo creado: $SOURCE_DIR/security_monitor.sh${NC}"
    fi
fi

echo -e "\n${GREEN}${BOLD}¡Instalación completada!${NC}"
echo -e "${YELLOW}Para ejecutar el monitor, use:${NC}"
echo -e "${BLUE}cd $INSTALL_DIR && sudo ./main.sh${NC}"

if [ "$INSTALL_DIR" != "$SOURCE_DIR" ] && [[ "$create_shortcut" =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}O use el acceso directo:${NC}"
    echo -e "${BLUE}sudo $SOURCE_DIR/security_monitor.sh${NC}"
fi

echo ""
echo -e "${YELLOW}Recuerde que necesita privilegios de administrador (sudo) para acceder a todos los logs.${NC}"
