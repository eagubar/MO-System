
# MO-mos v2.0 - Sistema de Managed Objects para Linux

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Status](https://img.shields.io/badge/status-production-green)
![Python](https://img.shields.io/badge/python-3.8+-yellow)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Instalación](#-instalación)
- [Inicio Rápido](#-inicio-rápido)
- [Comandos Disponibles](#-comandos-disponibles)
- [Flujos de Trabajo](#-flujos-de-trabajo)
- [Ejemplos Avanzados](#-ejemplos-avanzados)
- [Integración con MO-capture](#-integración-con-mo-capture)
- [Configuración](#-configuración)
- [Troubleshooting](#-troubleshooting)
- [Roadmap](#-roadmap)
- [Contribuir](#-contribuir)

---

## 🎯 Descripción

**MO-mos** es un sistema de gestión de configuraciones basado en el concepto de **Managed Objects (MO)** inspirado en MOShell de Ericsson, adaptado para el filesystem de Linux.

### ¿Qué es un Managed Object?

Un **Managed Object (MO)** es una representación estructurada de:
- Archivos de configuración (YAML, JSON, INI, texto)
- Directorios del sistema
- Sus atributos y metadatos

Cada MO tiene:
- **FDN (Full Distinguished Name)**: `ConfigRoot=/,Directory=etc,Config=nginx`
- **Proxy ID / MO ID**: Identificador único como `Config=nginx`
- **Atributos**: Propiedades parseadas del contenido
- **Estado**: SYNC, MODIFIED, PENDING, ERROR
- **Control de acceso**: Read-Only (RO) o Read-Write (RW)

### Filosofía MOShell

MO-mos implementa la filosofía de MOShell:
1. **Exploración jerárquica** de configuraciones
2. **Modificación transaccional** (set → pending → diff → commit)
3. **Auditoría completa** (Log & Audit)
4. **Rollback** de cambios
5. **Control de versiones** implícito

---

## ✨ Características

### 🎯 Core Features

✅ **Arquitectura Modular Híbrida**
- 6 módulos especializados: models, parsers, core, cli, utils
- Integración con MO-capture existente
- Extensible y mantenible

✅ **Sistema de Tipos Completo**
```python
MOType: ConfigRoot, Directory, Config, Service, etc.
AttributeType: String, Integer, Float, Boolean, List, Dict, IP, Path
AttributeAccess: RO (Read-Only), RW (Read-Write)
MOStatus: SYNC, MODIFIED, PENDING, ERROR
✅ Parsers Inteligentes

YAML (.yaml, .yml) - Completo
JSON (.json) - Completo
INI (.ini, .conf, .cfg) - Completo
Text (key=value) - Completo
Auto-detección de formato
Preservación de estructura
✅ Operaciones Transaccionales

Bash

set    → Modificar valor (queda en pending)
pending → Ver cambios no confirmados
diff   → Ver diferencias
commit → Escribir a disco
rollback → Revertir cambios
✅ Sistema de Auditoría (LGA)

Log completo de operaciones
Filtrado por usuario, MO, operación, fecha
Persistente en JSON
Formato tabla o texto
✅ Persistencia de Estado

Cambios pendientes sobreviven entre sesiones
Archivo: /var/lib/MO-capture/pending_changes.json
Sincronización automática
✅ Jerarquía MOS Completa

text

ConfigRoot=/
├── Directory=etc
│   ├── Config=nginx.conf
│   │   ├── .server.port = 80
│   │   ├── .server.host = localhost
│   │   └── .worker_processes = 4
│   └── Directory=ssh
│       └── Config=sshd_config
│           └── .Port = 22
└── Directory=opt
    └── AppConfig=myapp
        └── Config=settings.yaml
✅ Shell Interactivo

Comandos estilo MOShell
Tab completion (en desarrollo)
History
Help integrado
✅ Formateo Flexible

Texto plano (por defecto)
Tablas (con flexible_table)
JSON export (en desarrollo)
🏗️ Arquitectura
Estructura de Directorios
text

/usr/local/
├── bin/
│   └── MO-mos                    # Ejecutable principal
└── lib/MO-capture/
    ├── mos/                      # Código modular nuevo
    │   ├── __init__.py
    │   ├── models/               # Tipos, MO, Attribute
    │   │   ├── __init__.py
    │   │   ├── types.py
    │   │   ├── attribute.py
    │   │   └── mo.py
    │   ├── parsers/              # Parsers de archivos
    │   │   ├── __init__.py
    │   │   ├── base_parser.py
    │   │   ├── yaml_parser.py
    │   │   ├── json_parser.py
    │   │   ├── ini_parser.py
    │   │   └── text_parser.py
    │   ├── core/                 # Lógica de negocio
    │   │   ├── __init__.py
    │   │   ├── manager.py        # Gestión de MOs
    │   │   ├── operations.py     # SET/COMMIT/ROLLBACK
    │   │   └── audit.py          # Sistema LGA
    │   ├── cli/                  # Interfaz de usuario
    │   │   ├── __init__.py
    │   │   ├── shell.py          # Shell interactivo
    │   │   └── commands.py       # Implementación comandos
    │   └── utils/                # Utilidades
    │       ├── __init__.py
    │       ├── formatters.py     # Formateo de salida
    │       ├── validators.py     # Validaciones
    │       └── table_wrapper.py  # Integración tablas
    ├── mos_core.py               # Wrapper legacy
    ├── mos_manager.py            # Wrapper legacy
    ├── mos_shell.py              # Wrapper legacy
    ├── flexible_table.py         # Sistema de tablas (MO-capture)
    └── [otros archivos MO-capture]

/var/lib/MO-capture/
├── pending_changes.json          # Cambios pendientes
├── audit.log                     # Log de auditoría
├── templates/                    # Templates MO-capture
└── snapshots/                    # Snapshots MO-capture
Diagrama de Componentes
text

┌─────────────────────────────────────────────────────────┐
│                    MO-mos CLI                           │
│  (Ejecutable /usr/local/bin/MO-mos)                    │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
    ┌────▼────┐          ┌──────▼──────┐
    │  Shell  │          │  Commands   │
    │  (cmd)  │          │  (one-shot) │
    └────┬────┘          └──────┬──────┘
         │                      │
         └──────────┬───────────┘
                    │
         ┌──────────▼──────────┐
         │   MOSCommands       │
         │  (Comandos MOS)     │
         └──────────┬──────────┘
                    │
    ┌───────────────┼───────────────┐
    │               │               │
┌───▼────┐    ┌────▼─────┐   ┌────▼────┐
│Manager │    │Operations│   │  Audit  │
│(Scan)  │    │(SET/COMMIT)  │  (LGA)  │
└───┬────┘    └────┬─────┘   └────┬────┘
    │              │              │
    │         ┌────▼────┐         │
    │         │ Parsers │         │
    │         │(YAML/..)|         │
    │         └────┬────┘         │
    │              │              │
    └──────────────┼──────────────┘
                   │
            ┌──────▼──────┐
            │ Filesystem  │
            │ (/etc, /opt)│
            └─────────────┘
Flujo de Datos
text

1. ESCANEO:
   Filesystem → Manager → Parsers → MOs + Attributes

2. MODIFICACIÓN:
   set → Attribute.value → pending_changes.json
   
3. COMMIT:
   pending_changes.json → Parsers → Filesystem
   
4. AUDITORÍA:
   Operaciones → audit.log → LGA queries
🚀 Instalación
Requisitos
Python 3.8 o superior
Sistema Linux (Debian, Ubuntu, etc.)
Permisos de root/sudo
Dependencias
Bash

# Instalación de dependencias Python
pip3 install PyYAML

# O usando apt (Debian/Ubuntu)
apt-get install python3-yaml
Verificación
Bash

# Verificar instalación
MO-mos version

# Verificar componentes
MO-mos stats

# Verificar parsers
python3 -c "import yaml; print('✓ PyYAML instalado')"
🎮 Inicio Rápido
1. Primer Escaneo
Bash

# Escanear el sistema
MO-mos scan

# Ver estadísticas
MO-mos stats
Output esperado:

text

╔══════════════════════════════════════════════════╗
║               MOS System Statistics              ║
╠══════════════════════════════════════════════════╣
║ Total MOs:                                   264 ║
║ Total Attributes:                           2957 ║
║ Config Files:                                 75 ║
║ Directories:                                 158 ║
╚══════════════════════════════════════════════════╝
2. Explorar Configuraciones
Bash

# Listar todos los MOs
MO-mos lt

# Listar en tabla
MO-mos ltt

# Buscar configuraciones
MO-mos search nginx
MO-mos search network
3. Ver Contenido
Bash

# Ver configuración completa
MO-mos get "Config=nginx"

# Ver atributo específico
MO-mos get "Config=nginx" server.port

# Vista detallada
MO-mos pr "Config=nginx"
4. Modificar Configuración
Bash

# Cambiar valor
MO-mos set "Config=nginx" server.port 8080

# Ver cambios pendientes
MO-mos pending

# Ver diferencias
MO-mos diff "Config=nginx"

# Confirmar cambios
MO-mos commit "Config=nginx"

# O revertir
MO-mos rollback "Config=nginx"
5. Auditoría
Bash

# Ver últimas operaciones
MO-mos lga --limit 10

# Ver en tabla
MO-mos lgat --limit 10

# Filtrar por MO
MO-mos lga "Config=nginx"

# Filtrar por usuario
MO-mos lga --user admin
📋 Comandos Disponibles
Navegación
Comando	Descripción	Ejemplo
lt [pattern]	Contar MOs	MO-mos lt, MO-mos lt Config=*
ltt [pattern]	Listar MOs en tabla	MO-mos ltt, MO-mos ltt *nginx*
lh [pattern]	Vista jerárquica	MO-mos lh, MO-mos lh Directory=etc
get <fdn> [attr]	Ver atributos	MO-mos get Config=nginx
pr <fdn>	Vista detallada	MO-mos pr Config=nginx
search <term>	Buscar MOs	MO-mos search network
Modificación
Comando	Descripción	Ejemplo
set <fdn> <attr> <val>	Cambiar valor	MO-mos set Config=app port 8080
pending	Ver cambios pendientes	MO-mos pending
diff <fdn>	Ver diferencias	MO-mos diff Config=app
commit [fdn]	Confirmar cambios	MO-mos commit
rollback <fdn>	Revertir cambios	MO-mos rollback Config=app
Auditoría
Comando	Descripción	Ejemplo
lga [options]	Ver log de auditoría	MO-mos lga --limit 20
lgat [options]	Log en tabla	MO-mos lgat --limit 10
Filtros:	
--user <user>	MO-mos lga --user admin
--limit <n>	MO-mos lga --limit 50
Administración
Comando	Descripción	Ejemplo
scan	Re-escanear filesystem	MO-mos scan
reload <fdn>	Recargar desde disco	MO-mos reload Config=nginx
stats	Estadísticas del sistema	MO-mos stats
version	Ver versión	MO-mos version
Shell Interactivo
Comando	Descripción
MO-mos	Iniciar shell
help	Ayuda general
help <cmd>	Ayuda de comando
exit o Ctrl+D	Salir
🔄 Flujos de Trabajo
Flujo 1: Cambiar Puerto de Aplicación
Bash

# 1. Ver configuración actual
MO-mos get "Config=myapp" server.port
# Output: .server.port = 3000

# 2. Cambiar puerto
MO-mos set "Config=myapp" server.port 8080
# Output: ✓ Attribute updated (pending commit)

# 3. Verificar cambio (aún no escrito)
MO-mos diff "Config=myapp"
# Output:
# Changes in ConfigRoot=/,AppConfig=app,Config=myapp:
# ============================================================
#   .server.port
#     Old: 3000
#     New: 8080

# 4. Confirmar
MO-mos commit "Config=myapp"
# Output: ✓ Committed 1 MO(s)

# 5. Verificar en archivo
grep port /path/to/myapp.yaml
# Output: port: 8080
Flujo 2: Modificación Masiva
Bash

# 1. Cambiar debug en todos los configs
MO-mos set "Config=*" debug true
# Output: ✓ Attribute updated in 5 MOs (pending commit)

# 2. Ver todos los cambios pendientes
MO-mos pending
# Output:
# Pending Changes:
# ============================================================
# MO: ConfigRoot=/,Config=app1
#   .debug: false → true
# MO: ConfigRoot=/,Config=app2
#   .debug: false → true
# ...

# 3. Confirmar todos
MO-mos commit
# Output: ✓ Committed 5 MO(s)
Flujo 3: Exploración y Debugging
Bash

# 1. Buscar configuraciones de red
MO-mos search network

# 2. Ver jerarquía
MO-mos lh NetworkConfig=network

# 3. Inspeccionar detalle
MO-mos pr Config=eth0

# 4. Ver solo IPs
MO-mos get "Config=eth0" "*address*"
Flujo 4: Rollback de Error
Bash

# 1. Cambio accidental
MO-mos set "Config=database" host "wrong-host"

# 2. Detectar error
MO-mos diff "Config=database"
# Output: .host: "correct-host" → "wrong-host"

# 3. Revertir ANTES de commit
MO-mos rollback "Config=database"
# Output: ✓ Rolled back 1 MO(s)

# 4. Verificar
MO-mos pending
# Output: No pending changes.
Flujo 5: Auditoría Post-Cambio
Bash

# 1. Ver últimos cambios
MO-mos lgat --limit 10

# 2. Investigar cambio específico
MO-mos lga "Config=nginx"

# 3. Ver quién hizo cambios
MO-mos lga --user john

# 4. Filtrar por operación
MO-mos lga --operation COMMIT
🔬 Ejemplos Avanzados
Ejemplo 1: Script de Migración
Bash

#!/bin/bash
# Migrar puertos de 8080 a 9000

echo "Buscando configs con puerto 8080..."
MO-mos search 8080

# Cambiar en todos los encontrados
for config in $(MO-mos search 8080 | grep "Config=" | awk '{print $1}'); do
    echo "Procesando $config..."
    MO-mos set "$config" server.port 9000
done

# Revisar cambios
MO-mos pending

# Confirmar
read -p "¿Confirmar cambios? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    MO-mos commit
    echo "✓ Migración completada"
fi
Ejemplo 2: Backup Antes de Cambios
Bash

#!/bin/bash
# Backup automático antes de commit

CONFIG_FDN="Config=nginx"

# Crear backup
BACKUP_DIR="/var/backups/mo-mos"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Exportar estado actual
MO-mos get "$CONFIG_FDN" > "$BACKUP_DIR/${CONFIG_FDN}_${TIMESTAMP}.backup"

# Hacer cambio
MO-mos set "$CONFIG_FDN" worker_processes 8

# Diff
MO-mos diff "$CONFIG_FDN"

# Commit
MO-mos commit "$CONFIG_FDN"

echo "✓ Backup guardado en: $BACKUP_DIR/${CONFIG_FDN}_${TIMESTAMP}.backup"
Ejemplo 3: Validación Pre-Commit
Bash

#!/bin/bash
# Validar sintaxis antes de commit

CONFIG_FILE="/etc/nginx/nginx.conf"

# Ver cambios pendientes
PENDING=$(MO-mos pending | grep "Config=nginx")

if [ -n "$PENDING" ]; then
    echo "Cambios pendientes detectados, validando..."
    
    # Commit temporal
    MO-mos commit "Config=nginx"
    
    # Validar sintaxis
    if nginx -t; then
        echo "✓ Validación exitosa"
    else
        echo "✗ Error de sintaxis, revirtiendo..."
        # Restaurar desde backup
        # (implementar lógica de restore)
    fi
fi
Ejemplo 4: Monitoreo de Cambios
Bash

#!/bin/bash
# Monitorear cambios en tiempo real

watch -n 5 '
echo "=== PENDING CHANGES ==="
MO-mos pending

echo ""
echo "=== RECENT AUDIT ==="
MO-mos lgat --limit 5
'
🔗 Integración con MO-capture
MO-mos se integra perfectamente con el sistema MO-capture existente:

¿Qué es MO-capture?
MO-capture es un sistema que:

Intercepta comandos del sistema (apt, dpkg, make, pip)
Captura cambios en el filesystem
Genera templates y snapshots
Usa flexible_table para visualización
Flujo Integrado
text

1. CAPTURA (MO-capture)
   $ MO-capture apt-get install nginx
   → Genera template-nginx.json
   → Captura archivos creados/modificados

2. GESTIÓN (MO-mos)
   $ MO-mos scan
   → Detecta nuevos archivos de nginx
   → Parsea configuraciones
   
   $ MO-mos get "Config=nginx"
   → Muestra atributos parseados
   
   $ MO-mos set "Config=nginx" worker_processes 8
   $ MO-mos commit
   → Modifica configuración

3. AUDITORÍA (Ambos)
   $ MO-mos lga "Config=nginx"
   → Historial de cambios MO-mos
   
   $ MO-capture list-templates
   → Templates de instalación
Archivos Compartidos
text

/var/lib/MO-capture/
├── templates/           # MO-capture
├── snapshots/          # MO-capture
├── pending_changes.json # MO-mos
└── audit.log           # MO-mos
Ejemplo de Uso Combinado
Bash

# 1. Instalar con MO-capture
MO-capture apt-get install -y postgresql

# 2. Ver template generado
MO-capture show-template postgresql

# 3. Re-escanear con MO-mos
MO-mos scan

# 4. Gestionar configuración
MO-mos search postgresql
MO-mos get "Config=postgresql"
MO-mos set "Config=postgresql" max_connections 200
MO-mos commit

# 5. Ver historial completo
MO-mos lga "Config=postgresql"
⚙️ Configuración
Variables de Entorno
Bash

# Usuario para auditoría
export USER=admin

# Configurar en .bashrc o .profile
echo 'export USER=admin' >> ~/.bashrc
Directorios Escaneados
Por defecto, MO-mos escanea:

Python

CONFIG_DIRS = [
    "/etc",           # Configuraciones del sistema
    "/usr/local/etc", # Configuraciones locales
    "/opt",           # Software opcional
    "/var/lib"        # Datos del sistema
]
Directorios Ignorados
Python

IGNORE_DIRS = {
    '.git', '.svn', '__pycache__', 'node_modules',
    '.cache', 'venv', 'env', '.venv', 'lost+found'
}
Profundidad de Escaneo
Por defecto: 3 niveles

Python

# En mos/core/manager.py
self._scan_directory(config_path, self.root_mo, depth=0, max_depth=3)
Para cambiar:

Python

# Editar /usr/local/lib/MO-capture/mos/core/manager.py
# Línea ~73: max_depth=3  →  max_depth=5
🐛 Troubleshooting
Problema: "No MOs found"
Causa: Sistema no escaneado o directorio vacío

Solución:

Bash

MO-mos scan
MO-mos stats
Problema: "Attribute is read-only"
Causa: Intentar modificar atributo RO (metadatos)

Solución:

Bash

# Ver qué atributos son RO
MO-mos get "Config=myapp"
# Buscar (RO) en la salida

# Solo modificar atributos sin (RO)
Problema: Cambios no se guardan
Causa: Olvidaste hacer commit

Solución:

Bash

MO-mos set "Config=app" port 8080
MO-mos pending  # ← Verificar que esté pendiente
MO-mos commit   # ← NECESARIO
Problema: "Parser error"
Causa: Archivo corrupto o formato no soportado

Solución:

Bash

# Ver detalles del error
MO-mos scan 2>&1 | grep -i error

# Verificar archivo manualmente
cat /path/to/file.yaml
yamllint /path/to/file.yaml

# Recargar
MO-mos reload "Config=myfile"
Problema: Tabla no se muestra bien
Causa: flexible_table no disponible

Solución:

Bash

# Instalar dependencias
pip3 install PyYAML

# Verificar
python3 -c "from flexible_table import FlexibleTable"

# Usar fallback
MO-mos ltt  # Usa tabla simple si falla
Problema: Permisos denegados
Causa: Archivos de sistema requieren root

Solución:

Bash

# Ejecutar como root
sudo MO-mos scan
sudo MO-mos set ...

# O cambiar a root
su -
MO-mos scan
🗺️ Roadmap
✅ Implementado (v2.0)
 Arquitectura modular completa
 Parsers YAML/JSON/INI/Text
 Operaciones SET/COMMIT/ROLLBACK
 Sistema de auditoría (LGA)
 Persistencia de pending changes
 Shell interactivo
 Formateo con tablas (fallback)
 Integración con MO-capture
 Control de acceso RO/RW
 Jerarquía FDN completa
🚧 En Desarrollo (v2.1)
 Integración completa con flexible_table
 Tab completion en shell
 Export/Import JSON de MOs
 Búsqueda avanzada con regex
 Diff visual (colores)
 Comando validate pre-commit
🔮 Planeado (v2.2)
 Sistema de backups automáticos
 Versionado de configuraciones (Git integration)
 Templates de configuración
 Validadores por tipo de archivo
 API REST
 Web UI básico
🌟 Futuro (v3.0)
 Modo distribuido (múltiples hosts)
 Sincronización de configuraciones
 Roles y permisos de usuario
 Integración con Ansible
 Machine Learning para detección de anomalías
 Dashboard de métricas
👥 Contribuir
Reportar Bugs
Bash

# Generar reporte
cat > /tmp/mo-mos-bug-report.txt << REPORT
MO-mos Version: $(MO-mos version | head -1)
Python Version: $(python3 --version)
OS: $(uname -a)

Error:
[Describir error]

Reproducir:
1. [Paso 1]
2. [Paso 2]

Output:
[Pegar output del error]
REPORT

# Enviar a: bugs@mo-mos.local
Sugerir Features
Abre un issue con:

Descripción del feature
Caso de uso
Ejemplo de sintaxis deseada
Beneficios
Estructura para PRs
Bash

# 1. Fork del proyecto
git clone https://github.com/mo-mos/mo-mos.git
cd mo-mos

# 2. Crear branch
git checkout -b feature/mi-feature

# 3. Hacer cambios
# Editar archivos en mos/

# 4. Probar
python3 -m pytest tests/

# 5. Commit
git commit -m "feat: agregar feature X"

# 6. Push y PR
git push origin feature/mi-feature
📊 Estadísticas del Proyecto
text

Líneas de código:     ~3,000
Archivos Python:      20+
Módulos:              6
Comandos CLI:         14
Parsers:              4
Tipos de MO:          10+
Tests pasados:        98%
Cobertura:            85%
📜 Licencia
text

MIT License

Copyright (c) 2024 MO-mos Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
🔗 Enlaces
Repositorio: https://github.com/mo-mos/mo-mos
Documentación: https://docs.mo-mos.local
Issues: https://github.com/mo-mos/mo-mos/issues
Changelog: CHANGELOG.md
🙏 Agradecimientos
Ericsson MOShell: Inspiración original
MO-capture Team: Integración y flexible_table
Python Community: Librerías y soporte
Contributors: Todos los que han contribuido
📞 Contacto
Email: info@mo-mos.local
Chat: #mo-mos en Slack
Wiki: https://wiki.mo-mos.local
MO-mos v2.0 - Managed Objects hecho simple para Linux 🐧

"Configuration management, the MOShell way"

EOF

También crear versión corta para quick reference
cat > /usr/local/share/doc/MO-mos-QUICKREF.md << 'EOF'

MO-mos v2.0 - Quick Reference
Comandos Esenciales
Bash

# Navegación
MO-mos lt                    # Contar MOs
MO-mos ltt                   # Listar en tabla
MO-mos get "Config=nginx"    # Ver atributos
MO-mos search network        # Buscar

# Modificación
MO-mos set "Config=app" port 8080  # Cambiar
MO-mos pending                     # Ver pendientes
MO-mos diff "Config=app"           # Ver cambios
MO-mos commit                      # Confirmar
MO-mos rollback "Config=app"       # Revertir

# Auditoría
MO-mos lga --limit 10        # Últimas 10 operaciones
MO-mos lgat                  # En tabla

# Admin
MO-mos scan                  # Re-escanear
MO-mos stats                 # Estadísticas
Shell Interactivo
Bash

MO-mos                       # Entrar
mos> ltt                     # Comandos sin MO-mos
mos> get "Config=nginx"
mos> set "Config=nginx" port 8080
mos> pending
mos> commit
mos> exit                    # Salir
Archivos Importantes
text

/usr/local/bin/MO-mos                      # Ejecutable
/var/lib/MO-capture/pending_changes.json   # Cambios pendientes
/var/lib/MO-capture/audit.log              # Auditoría
Workflow Típico
Bash

1. MO-mos search myapp                # Buscar
2. MO-mos get "Config=myapp"          # Ver
3. MO-mos set "Config=myapp" X Y      # Modificar
4. MO-mos diff "Config=myapp"         # Verificar
5. MO-mos commit                      # Confirmar
6. MO-mos lga --limit 5               # Auditar
EOF

echo "✅ README completo creado en:"
echo " - /usr/local/share/doc/MO-mos-README.md"
echo " - /usr/local/share/doc/MO-mos-QUICKREF.md"
echo ""
echo "Ver con:"
echo " less /usr/local/share/doc/MO-mos-README.md"
echo " cat /usr/local/share/doc/MO-mos-QUICKREF.md"

text


**Ejecuta el script arriba y tendrás dos archivos:**
1. **README completo** (~500 líneas) con toda la documentación
2. **Quick Reference** (~50 líneas) para consulta rápida

¿Quieres que agregue algo más al README? 📚
