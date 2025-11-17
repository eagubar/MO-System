#!/bin/bash
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║               MO-capture v2.1 - Test Ultimate                 ║"
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

# Crear programa de prueba corregido
cat > mo-test-v2.c << 'CODIGO'
#include <stdio.h>
int main() { 
    printf("¡MO-capture v2.1 funciona perfectamente!\\n");
    printf("Snapshots pre y post tienen IDs diferentes.\\n");
    return 0; 
}
CODIGO

# Crear Makefile con TABULADORES (no espacios)
cat > Makefile << 'MAKEFILE'
all: mo-test-v2

mo-test-v2: mo-test-v2.c
gcc -o mo-test-v2 mo-test-v2.c

install:
install -m 755 mo-test-v2 /usr/local/bin/mo-test-v2
MAKEFILE

# Verificar que el Makefile usa tabuladores
echo "Verificando Makefile:"
cat -A Makefile | head -3

# Compilar e instalar
echo "Compilando..."
make
echo "Instalando con MO-capture..."
MO-capture make install

echo ""
echo "=== Test 4: Verificar instalación ==="
if command -v mo-test-v2 >/dev/null 2>&1; then
    echo "✓ Programa instalado correctamente"
    mo-test-v2
else
    echo "✗ Programa no se instaló"
    echo "Intentando instalación manual para diagnóstico..."
    make install
    if command -v mo-test-v2 >/dev/null 2>&1; then
        echo "✓ Instalación manual funciona"
        mo-test-v2
    else
        echo "✗ La instalación manual también falla"
    fi
fi

echo ""
echo "=== Test 5: Estado final ==="
MO-capture status

echo ""
echo "=== Test 6: Verificar IDs únicos ==="
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
                echo "  ✓ Snapshots diferentes - CORRECTO"
            else
                echo "  ✗ Snapshots iguales - ERROR"
            fi
        fi
    fi
done

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   Test Ultimate Completado                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
