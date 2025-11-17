#!/bin/bash
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         MO-capture v1.1 - Test de Instalación                ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "=== Limpieza inicial ==="
MO-capture reset

echo ""
echo "=== Test 1: Estado del sistema ==="
MO-capture status

echo ""
echo "=== Test 2: Captura de instalación de paquete simple ==="
echo "[→] Instalando 'sl' con MO-capture..."
MO-capture apt-get install -y sl

echo ""
echo "=== Test 3: Listar snapshots creados ==="
MO-capture list-snapshots

echo ""
echo "=== Test 4: Listar templates generados ==="
MO-capture list-templates

echo ""
echo "=== Test 5: Verificar último template ==="
latest_template=$(ls -t /var/lib/MO-capture/templates/*.json 2>/dev/null | head -1)
if [[ -n "$latest_template" && -f "$latest_template" ]]; then
    echo "[→] Template encontrado: $latest_template"
    MO-install --verify "$latest_template"
else
    echo "[→] No se encontraron templates válidos"
fi

echo ""
echo "=== Test 6: Ver contenido de template ==="
if [[ -n "$latest_template" && -f "$latest_template" ]]; then
    echo "[→] Información del template:"
    jq -r '.MO_template | "  Comando: \(.command)\n  Timestamp: \(.timestamp)\n  Sistema: \(.system)"' "$latest_template" 2>/dev/null || \
    grep -A5 '"MO_template"' "$latest_template" | head -10
else
    echo "[→] No hay template para mostrar"
fi

echo ""
echo "=== Test 7: Probar con instalación desde fuente ==="
cd /tmp
echo "[→] Creando proyecto de prueba..."
cat > test-app.c << 'TESTCODE'
#include <stdio.h>
int main() { 
    printf("¡Hola MO-capture!\\n");
    return 0; 
}
TESTCODE

cat > Makefile << 'TESTMAKE'
all: test-app
test-app: test-app.c
gcc -o test-app test-app.c
install:
install -m 755 test-app /usr/local/bin/mo-test-app
TESTMAKE

echo "[→] Compilando e instalando con MO-capture..."
MO-capture make install

echo ""
echo "=== Test 8: Verificar instalación ==="
if command -v mo-test-app >/dev/null 2>&1; then
    echo "[✓] Aplicación instalada correctamente"
    mo-test-app
else
    echo "[ ] Aplicación no encontrada"
fi

echo ""
echo "=== Test 9: Estado final del sistema ==="
MO-capture status

echo ""
echo "=== Test 10: Ver logs ==="
echo "[→] Últimas 5 líneas del log:"
tail -5 /var/log/MO-capture.log

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Test v1.1 Completado                                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
