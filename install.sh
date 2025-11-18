#!/usr/bin/env bash
################################################################################
# MO-capture Installation Script v2.1
################################################################################

set -euo pipefail

readonly VERSION="2.1"
readonly INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly LOG_FILE="/tmp/mo-capture-install-$(date +%Y%m%d-%H%M%S).log"

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Rutas de instalación
readonly BIN_DIR="/usr/local/bin"
readonly LIB_DIR="/usr/local/lib/MO-capture"
readonly ETC_DIR="/etc/MO-capture"
readonly VAR_DIR="/var/lib/MO-capture"
readonly LOG_DIR="/var/log"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE" >&2
}

print_banner() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              MO-capture Installation Script                    ║
║          Sistema de Captura Declarativa para Linux             ║
║                        Version 2.1                             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script debe ejecutarse como root"
        log_info "Ejecuta: sudo $0 install"
        exit 1
    fi
}

check_files() {
    log_info "Verificando archivos de instalación..."

    local missing=0

    if [[ ! -f "$INSTALL_DIR/usr/local/bin/MO-capture" ]]; then
        log_error "No encontrado: usr/local/bin/MO-capture"
        ((missing++))
    fi

    if [[ ! -f "$INSTALL_DIR/usr/local/bin/MO-install" ]]; then
        log_error "No encontrado: usr/local/bin/MO-install"
        ((missing++))
    fi

    if [[ ! -f "$INSTALL_DIR/usr/local/lib/MO-capture/template-generator.py" ]]; then
        log_error "No encontrado: usr/local/lib/MO-capture/template-generator.py"
        ((missing++))
    fi

    if [[ ! -f "$INSTALL_DIR/etc/MO-capture/config.yaml" ]]; then
        log_warning "No encontrado: etc/MO-capture/config.yaml (se creará uno por defecto)"
    fi

    if [[ $missing -gt 0 ]]; then
        log_error "Faltan $missing archivos necesarios"
        log_info "Directorio actual: $INSTALL_DIR"
        log_info "Archivos encontrados:"
        find "$INSTALL_DIR" -type f 2>/dev/null || true
        exit 1
    fi

    log_success "Todos los archivos necesarios encontrados"
}

create_directories() {
    log_info "Creando estructura de directorios..."

    mkdir -p "$BIN_DIR"
    mkdir -p "$LIB_DIR"
    mkdir -p "$ETC_DIR"
    mkdir -p "$VAR_DIR/snapshots"
    mkdir -p "$VAR_DIR/templates"

    log_success "Directorios creados"
}

backup_existing() {
    if [[ -f "$BIN_DIR/MO-capture" ]]; then
        local backup_dir="/tmp/mo-capture-backup-$(date +%Y%m%d-%H%M%S)"
        log_warning "Instalación existente detectada"
        log_info "Creando backup en: $backup_dir"

        mkdir -p "$backup_dir"
        [[ -f "$BIN_DIR/MO-capture" ]] && cp "$BIN_DIR/MO-capture" "$backup_dir/"
        [[ -f "$BIN_DIR/MO-install" ]] && cp "$BIN_DIR/MO-install" "$backup_dir/"
        [[ -d "$LIB_DIR" ]] && cp -r "$LIB_DIR" "$backup_dir/"
        [[ -d "$ETC_DIR" ]] && cp -r "$ETC_DIR" "$backup_dir/etc-backup"

        log_success "Backup creado: $backup_dir"
    fi
}

install_files() {
    log_info "Instalando archivos del sistema..."

    # Binarios
    cp "$INSTALL_DIR/usr/local/bin/MO-capture" "$BIN_DIR/"
    chmod +x "$BIN_DIR/MO-capture"
    log_success "Instalado: MO-capture"

    cp "$INSTALL_DIR/usr/local/bin/MO-install" "$BIN_DIR/"
    chmod +x "$BIN_DIR/MO-install"
    log_success "Instalado: MO-install"

    # Librería
    cp "$INSTALL_DIR/usr/local/lib/MO-capture/template-generator.py" "$LIB_DIR/"
    chmod +x "$LIB_DIR/template-generator.py"
    log_success "Instalado: template-generator.py"

    # Configuración
    if [[ -f "$INSTALL_DIR/etc/MO-capture/config.yaml" ]]; then
        cp "$INSTALL_DIR/etc/MO-capture/config.yaml" "$ETC_DIR/"
        chmod 644 "$ETC_DIR/config.yaml"
        log_success "Instalado: config.yaml"
    else
        create_default_config
    fi

    # Log
    touch "$LOG_DIR/MO-capture.log"
    chmod 644 "$LOG_DIR/MO-capture.log"

    log_success "Todos los archivos instalados"
}

create_default_config() {
    log_info "Creando configuración por defecto..."

    cat > "$ETC_DIR/config.yaml" << 'CONFIGEOF'
version: "2.1"
system: "Devuan13-LXC"

capture_directories:
  - /usr/local
  - /etc
  - /opt
  - /var/lib

ignore_patterns:
  - "*.log"
  - "*.tmp"
  - "*.cache"
  - "/tmp/*"
  - "/var/tmp/*"
  - "/dev/*"
  - "/proc/*"
  - "/sys/*"

intercepted_commands:
  - apt-get
  - apt
  - dpkg
  - make
  - pip
  - pip3

logging:
  level: "INFO"
  file: "/var/log/MO-capture.log"
  max_size: "10MB"

snapshots:
  max_count: 50
  auto_cleanup: true

strace:
  max_log_size: "10MB"
  trace_patterns:
    - file
    - chmod
    - chown
CONFIGEOF

    chmod 644 "$ETC_DIR/config.yaml"
    log_success "Configuración creada"
}

verify_installation() {
    log_info "Verificando instalación..."

    local errors=0

    [[ ! -x "$BIN_DIR/MO-capture" ]] && { log_error "MO-capture no ejecutable"; ((errors++)); }
    [[ ! -x "$BIN_DIR/MO-install" ]] && { log_error "MO-install no ejecutable"; ((errors++)); }
    [[ ! -f "$LIB_DIR/template-generator.py" ]] && { log_error "template-generator.py no encontrado"; ((errors++)); }
    [[ ! -f "$ETC_DIR/config.yaml" ]] && { log_error "config.yaml no encontrado"; ((errors++)); }
    [[ ! -d "$VAR_DIR/snapshots" ]] && { log_error "Directorio snapshots no creado"; ((errors++)); }
    [[ ! -d "$VAR_DIR/templates" ]] && { log_error "Directorio templates no creado"; ((errors++)); }

    if ! command -v MO-capture &>/dev/null; then
        log_error "MO-capture no está en PATH"
        ((errors++))
    fi

    if [[ $errors -gt 0 ]]; then
        log_error "Instalación completada con $errors errores"
        return 1
    fi

    log_success "Verificación completada - Sin errores"
    return 0
}

test_functionality() {
    log_info "Probando funcionalidad..."

    if MO-capture version &>/dev/null; then
        log_success "Comando 'MO-capture version' funciona"
    else
        log_warning "Comando 'MO-capture version' no respondió"
    fi

    if python3 "$LIB_DIR/template-generator.py" --help &>/dev/null; then
        log_success "template-generator.py funciona"
    else
        log_warning "template-generator.py no respondió"
    fi
}

uninstall() {
    log_warning "Iniciando desinstalación..."

    read -p "¿Desinstalar MO-capture? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

    read -p "¿Conservar datos (snapshots/templates)? (Y/n) " -n 1 -r
    echo
    local keep_data=true
    [[ $REPLY =~ ^[Nn]$ ]] && keep_data=false

    # Backup
    local backup_dir="/tmp/mo-capture-uninstall-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    [[ -d "$VAR_DIR" ]] && cp -r "$VAR_DIR" "$backup_dir/" 2>/dev/null || true
    [[ -d "$ETC_DIR" ]] && cp -r "$ETC_DIR" "$backup_dir/" 2>/dev/null || true
    log_info "Backup en: $backup_dir"

    # Eliminar
    rm -f "$BIN_DIR/MO-capture"
    rm -f "$BIN_DIR/MO-install"
    rm -rf "$LIB_DIR"
    rm -rf "$ETC_DIR"

    if [[ "$keep_data" == false ]]; then
        rm -rf "$VAR_DIR"
        rm -f "$LOG_DIR/MO-capture.log"
    else
        log_info "Datos conservados en: $VAR_DIR"
    fi

    log_success "Desinstalación completada"
}

show_help() {
    cat << EOF
Uso: $0 [OPCIÓN]

Opciones:
    install     Instalar MO-capture (por defecto)
    uninstall   Desinstalar MO-capture
    verify      Solo verificar instalación
    help        Mostrar esta ayuda

Ejemplos:
    $0 install
    $0 verify
    sudo $0 uninstall

EOF
}

main() {
    local action="${1:-install}"

    case "$action" in
        install)
            print_banner
            echo "================================================================"

            check_root
            check_files
            backup_existing
            create_directories
            install_files

            echo "================================================================"
            verify_installation
            test_functionality

            echo "================================================================"
            log_success "¡Instalación completada exitosamente!"
            echo ""
            log_info "Próximos pasos:"
            echo "  1. Verificar: MO-capture version"
            echo "  2. Estado: MO-capture status"
            echo "  3. Prueba: MO-capture apt-get install -y htop"
            echo ""
            log_info "Log: $LOG_FILE"
            ;;

        uninstall)
            check_root
            uninstall
            ;;

        verify)
            check_root
            verify_installation && test_functionality
            ;;

        help|--help|-h)
            show_help
            ;;

        *)
            log_error "Opción desconocida: $action"
            show_help
            exit 1
            ;;
    esac
}

main "$@"