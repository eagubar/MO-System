#!/bin/bash
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║               MO-capture v2.1 - Test Perfecto                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"

echo ""
echo "=== Limpieza inicial ==="
MO-capture reset

echo ""
echo "=== Test 1: Instalación APT ==="
MO-capture apt-get install -y net-tools

echo ""
echo "=== Test 2: Verificar snapshots únicos ==="
echo "Snapshots:"
MO-capture list-snapshots
echo ""
echo "Templates:"
MO-capture list-templates

echo ""
echo "=== Test 3: Compilación e instalación desde fuente ==="
cd /tmp

# Crear programa de prueba
cat > mo-test-perfect.c << 'CODIGO'
#include <stdio.h>
int main() { 
    printf("¡MO-capture v2.1 funciona perfectamente!\\n");
    printf("Snapshots pre y post tienen IDs diferentes.\\n");
    return 0; 
}
CODIGO

# Crear Makefile con TABULADORES correctos
cat > Makefile << 'MAKEFILE'
all: mo-test-perfect

mo-test-perfect: mo-test-perfect.c
gcc -o mo-test-perfect mo-test-perfect.c

install:
install -m 755 mo-test-perfect /usr/local/bin/mo-test-perfect
MAKEFILE

# Compilar e instalar
echo "Compilando..."
make
echo "Instalando con MO-capture..."
MO-capture make install

echo ""
echo "=== Test 4: Verificar instalación ==="
if command -v mo-test-perfect >/dev/null 2>&1; then
    echo "✓ Programa instalado correctamente"
    mo-test-perfect
else
    echo "✗ Programa no se instaló"
fi

echo ""
echo "=== Test 5: Verificar IDs únicos en templates ==="
templates=($(ls /var/lib/MO-capture/templates/*.json 2>/dev/null))
for template in "${templates[@]}"; do
    if [[ -f "$template" ]]; then
        echo "Template: $(basename "$template")"
        if command -v jq >/dev/null 2>&1; then
            pre_snap=$(jq -r '.MO_template.snapshots.pre' "$template")
            post_snap=$(jq -r '.MO_template.snapshots.post' "$template")
            echo "  Pre: $pre_snap"
            echo "  Post: $post_snap"
            if [[ "$pre_snap" != "$post_snap" ]]; then
                echo "  ✓ Snapshots diferentes - PERFECTO"
            else
                echo "  ✗ Snapshots iguales"
            fi
        fi
        echo "---"
    fi
done

echo ""
echo "=== Test 6: Estado final ==="
MO-capture status

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   ¡SISTEMA MO-capture LISTO!                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
