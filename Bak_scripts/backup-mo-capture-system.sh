#!/bin/bash
echo "=== BACKUP DEL SISTEMA MO-CAPTURE ==="

# Crear directorio temporal para el backup
BACKUP_DIR="/tmp/mo-capture-system-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backup directory: $BACKUP_DIR"

# Copiar los archivos del sistema
echo "Copiando archivos del sistema..."

# Binarios
mkdir -p "$BACKUP_DIR/usr/local/bin"
cp /usr/local/bin/MO-capture "$BACKUP_DIR/usr/local/bin/"
cp /usr/local/bin/MO-install "$BACKUP_DIR/usr/local/bin/"

# Librerías
mkdir -p "$BACKUP_DIR/usr/local/lib/MO-capture"
cp /usr/local/lib/MO-capture/template-generator.py "$BACKUP_DIR/usr/local/lib/MO-capture/"

# Configuración
mkdir -p "$BACKUP_DIR/etc/MO-capture"
cp /etc/MO-capture/config.yaml "$BACKUP_DIR/etc/MO-capture/"

# Scripts de prueba (opcionales)
mkdir -p "$BACKUP_DIR/root"
cp /root/MO-test-*.sh "$BACKUP_DIR/root/" 2>/dev/null || true

# Crear un script de restauración
cat > "$BACKUP_DIR/restore.sh" << 'RESTORE_EOF'
#!/bin/bash
echo "Restaurando MO-capture system..."

# Crear directorios si no existen
mkdir -p /usr/local/bin
mkdir -p /usr/local/lib/MO-capture
mkdir -p /etc/MO-capture
mkdir -p /var/lib/MO-capture/snapshots
mkdir -p /var/lib/MO-capture/templates
mkdir -p /var/log/MO-capture

# Copiar archivos
cp usr/local/bin/MO-capture /usr/local/bin/
cp usr/local/bin/MO-install /usr/local/bin/
cp usr/local/lib/MO-capture/template-generator.py /usr/local/lib/MO-capture/
cp etc/MO-capture/config.yaml /etc/MO-capture/

# Dar permisos de ejecución
chmod +x /usr/local/bin/MO-capture
chmod +x /usr/local/bin/MO-install
chmod +x /usr/local/lib/MO-capture/template-generator.py

echo "Restauración completada."
RESTORE_EOF

chmod +x "$BACKUP_DIR/restore.sh"

# Crear un tarball
TARBALL="/root/mo-capture-system-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$TARBALL" -C "$BACKUP_DIR" .

# Limpiar directorio temporal
rm -rf "$BACKUP_DIR"

echo "Backup completado: $TARBALL"
