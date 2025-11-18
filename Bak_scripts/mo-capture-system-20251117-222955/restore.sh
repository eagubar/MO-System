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
