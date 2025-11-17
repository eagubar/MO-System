#!/bin/bash
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                MO-capture v2.0 - Test Final                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "=== Limpieza inicial ==="
MO-capture reset

echo ""
echo "=== Estado inicial ==="
MO-capture status

echo ""
echo "=== Test 1: Instalación de paquete simple ==="
MO-capture apt-get install -y nano

echo ""
echo "=== Test 2: Verificar resultados ==="
echo "Snapshots:"
MO-capture list-snapshots
echo ""
echo "Templates:"
MO-capture list-templates

echo ""
echo "=== Test 3: Ver contenido de template ==="
latest_template=$(ls -t /var/lib/MO-capture/templates/*.json 2>/dev/null | head -1)
if [[ -n "$latest_template" && -f "$latest_template" ]]; then
    echo "Template: $(basename "$latest_template")"
    echo "Contenido:"
    if command -v jq >/dev/null 2>&1; then
        jq '.' "$latest_template" | head -20
    else
        head -10 "$latest_template"
    fi
else
    echo "No se encontraron templates"
fi

echo ""
echo "=== Test 4: Instalación desde fuente ==="
cd /tmp
cat > mo-test-program.c << 'CODIGO'
#include <stdio.h>
int main() { 
    printf("¡MO-capture v2.0 funciona perfectamente!\\n");
    return 0; 
}
CODIGO

cat > Makefile << 'MAKEFILE'
all: mo-test-program
mo-test-program: mo-test-program.c
gcc -o mo-test-program mo-test-program.c
install:
install -m 755 mo-test-program /usr/local/bin/mo-test-v2
MAKEFILE

MO-capture make install

echo ""
echo "=== Test 5: Verificar programa instalado ==="
if command -v mo-test-v2 >/dev/null 2>&1; then
    echo "✓ Programa instalado correctamente"
    mo-test-v2
else
    echo "✗ Programa no se instaló"
fi

echo ""
echo "=== Test 6: Estado final ==="
MO-capture status

echo ""
echo "=== Test 7: Ver logs ==="
echo "Últimas entradas:"
tail -5 /var/log/MO-capture.log

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                      Test Final Completado                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
