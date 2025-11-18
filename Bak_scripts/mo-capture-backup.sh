#!/bin/bash
echo "=== CREANDO BACKUP DE MO-CAPTURE ==="
echo "Timestamp: $(date)"
echo ""

# Crear directorio de backup
BACKUP_DIR="/root/mo-capture-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Directorio de backup: $BACKUP_DIR"

# 1. Backup de binarios principales
echo "1. Copiando binarios..."
mkdir -p "$BACKUP_DIR/usr/local/bin"
cp -v /usr/local/bin/MO-capture "$BACKUP_DIR/usr/local/bin/"
cp -v /usr/local/bin/MO-install "$BACKUP_DIR/usr/local/bin/"

# 2. Backup de librerías
echo "2. Copiando librerías..."
mkdir -p "$BACKUP_DIR/usr/local/lib/MO-capture"
cp -v /usr/local/lib/MO-capture/template-generator.py "$BACKUP_DIR/usr/local/lib/MO-capture/"

# 3. Backup de configuración
echo "3. Copiando configuración..."
mkdir -p "$BACKUP_DIR/etc/MO-capture"
cp -v /etc/MO-capture/config.yaml "$BACKUP_DIR/etc/MO-capture/"

# 4. Backup de scripts de test
echo "4. Copiando scripts de test..."
cp -v /root/MO-test-*.sh "$BACKUP_DIR/" 2>/dev/null || true
cp -v /root/MO-*.sh "$BACKUP_DIR/" 2>/dev/null || true

# 5. Backup de estructura de directorios (solo info)
echo "5. Guardando estructura de directorios..."
tree /etc/MO-capture /usr/local/lib/MO-capture /var/lib/MO-capture 2>/dev/null > "$BACKUP_DIR/directory-structure.txt" || \
ls -la /etc/MO-capture /usr/local/lib/MO-capture /var/lib/MO-capture > "$BACKUP_DIR/directory-structure.txt" 2>/dev/null

# 6. Backup de información del sistema
echo "6. Recolectando información del sistema..."
{
    echo "=== MO-CAPTURE SYSTEM INFO ==="
    echo "Backup created: $(date)"
    echo "Hostname: $(hostname)"
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
    echo "Kernel: $(uname -r)"
    echo ""
    echo "=== MO-CAPTURE VERSION ==="
    MO-capture version
    echo ""
    echo "=== CURRENT STATUS ==="
    MO-capture status
    echo ""
    echo "=== FILE PERMISSIONS ==="
    ls -la /usr/local/bin/MO-* /usr/local/lib/MO-capture/ /etc/MO-capture/
} > "$BACKUP_DIR/system-info.txt"

# 7. Crear script de restauración

