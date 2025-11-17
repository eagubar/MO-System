#!/bin/bash
echo "=== MO-capture Test Simple ==="

echo "1. Estado inicial:"
MO-capture status

echo ""
echo "2. Instalando htop:"
MO-capture apt-get install -y htop

echo ""
echo "3. Estado después de instalación:"
MO-capture status

echo ""
echo "4. Listando templates:"
MO-capture list-templates

echo ""
echo "5. Verificando template:"
latest_template=$(ls -t /var/lib/MO-capture/templates/*.json 2>/dev/null | head -1)
if [[ -n "$latest_template" ]]; then
    echo "Template: $latest_template"
    if command -v jq >/dev/null 2>&1; then
        jq '.MO_template' "$latest_template"
    else
        echo "Contenido:"
        head -20 "$latest_template"
    fi
else
    echo "No se encontraron templates"
fi

echo ""
echo "=== Test Completado ==="
