# MO-capture - Sistema de Captura Declarativa para Linux
📋 Tabla de Contenidos
Visión General

Arquitectura del Sistema

Instalación y Configuración

Árbol de Componentes

Comandos y Funcionalidades

Flujo de Trabajo

Formatos y Estructuras

Mecanismos Internos

Mantenimiento

Solución de Problemas

🔍 Visión General
MO-capture es un sistema de captura declarativa que intercepta instalaciones tradicionales de software en Linux y genera templates JSON reproducibles. Transforma instalaciones imperativas (./configure && make && make install) en definiciones declarativas.

Filosofía de Diseño
text
Instalación Tradicional          MO-capture
     ↓                              ↓
Comandos imperativos        →   Templates declarativos
Cambios opacos              →   Cambios documentados
Instalación única           →   Replicabilidad infinita
Configuración manual        →   Configuración versionada
🏗️ Arquitectura del Sistema
Componentes Principales
text
MO-capture Core
├── Interceptor de Comandos
├── Sistema de Snapshots  
├── Generador de Templates
├── Motor de Logging
└── Gestor de Estado
Flujo Arquitectónico








📥 Instalación y Configuración
Requisitos del Sistema
bash
# Sistema operativo
Distribución: Devuan 13/Debian-based
Kernel: Linux 6.14.11-4-pve
Arquitectura: x86_64

# Dependencias
python3 (3.13.5+)
strace (6.13+)
inotify-tools
sqlite3
jq (1.7+)
build-essential
Instalación Automática
bash
# Descargar e instalar
wget -O - https://raw.githubusercontent.com/tu-repo/mo-capture/main/install.sh | bash

# O instalación manual
git clone https://github.com/tu-repo/mo-capture.git
cd mo-capture
sudo ./install.sh
Estructura de Instalación
text
/
├── etc/MO-capture/
│   ├── config.yaml              # Configuración principal
│   └── templates/               # Plantillas base
├── usr/local/bin/
│   ├── MO-capture              # Ejecutable principal
│   └── MO-install              # Instalador desde templates
├── usr/local/lib/MO-capture/
│   └── template-generator.py   # Motor de generación
└── var/lib/MO-capture/
    ├── snapshots/              # Snapshots del sistema
    ├── templates/              # Templates generados
    └── database.db            # Base de datos (futuro)
🌳 Árbol de Componentes
Núcleo del Sistema
text
MO-capture v2.1
├── Binarios Ejecutables
│   ├── /usr/local/bin/MO-capture
│   └── /usr/local/bin/MO-install
├── Librerías y Módulos
│   └── /usr/local/lib/MO-capture/template-generator.py
├── Configuración
│   └── /etc/MO-capture/config.yaml
├── Datos del Sistema
│   ├── /var/lib/MO-capture/snapshots/
│   ├── /var/lib/MO-capture/templates/
│   └── /var/log/MO-capture.log
└── Scripts de Soporte
    ├── /root/MO-test-*.sh
    └── /root/mo-capture-backup.sh
Estructura de Directorios de Datos
text
/var/lib/MO-capture/
├── snapshots/
│   ├── MO-snap-20251117-203300-622/
│   │   ├── files.txt          # Lista de archivos del sistema
│   │   ├── packages.txt       # Paquetes instalados (dpkg -l)
│   │   └── services.txt       # Servicios systemd
│   └── MO-snap-20251117-203301-100/
│       └── ...
├── templates/
│   ├── MO-template-MO-snap-20251117-203301-100.json
│   ├── MO-template-MO-snap-20251117-203301-156.json
│   └── ...
└── database.db                # Base de datos SQLite (futuro)
🎯 Comandos y Funcionalidades
Comandos Principales
Captura de Instalaciones
bash
# Capturar instalación de paquetes APT
MO-capture apt-get install -y <paquete>

# Capturar instalación desde fuente
MO-capture make install

# Capturar instalación Python
MO-capture pip3 install <paquete>

# Capturar instalación DPkg
MO-capture dpkg -i <paquete.deb>
Gestión del Sistema
bash
# Información del sistema
MO-capture version                    # Versión de MO-capture
MO-capture status                     # Estado general del sistema

# Gestión de datos
MO-capture list-snapshots            # Listar snapshots existentes
MO-capture list-templates            # Listar templates generados
MO-capture cleanup                   # Limpiar archivos temporales
MO-capture reset                     # Eliminar todos los snapshots y templates
MO-install (Instalación desde Templates)
bash
# Verificar template
MO-install --verify <template.json>

# Información del template
MO-install --info <template.json>

# Instalar desde template (futuro)
MO-install <template.json>
Comandos de Diagnóstico
bash
# Ver logs del sistema
tail -f /var/log/MO-capture.log

# Verificar integridad de instalación
ls -la /usr/local/bin/MO-*
ls -la /var/lib/MO-capture/

# Probar funcionamiento básico
MO-capture apt-get install -y htop
MO-capture list-templates
🔄 Flujo de Trabajo
Flujo de Captura Estándar
bash
# 1. Iniciar captura (implícito)
MO-capture apt-get install -y nginx

# 2. Proceso automático:
#    - Crear snapshot pre-instalación
#    - Ejecutar comando con strace
#    - Crear snapshot post-instalación  
#    - Analizar diferencias
#    - Generar template JSON

# 3. Ver resultados
MO-capture list-templates
MO-install --info /var/lib/MO-capture/templates/MO-template-*.json
Flujo de Instalación desde Fuente
bash
# 1. Descargar y preparar código
wget http://example.com/app-1.0.tar.gz
tar -xzf app-1.0.tar.gz
cd app-1.0

# 2. Configurar y compilar
./configure --prefix=/usr/local
make

# 3. Instalar con captura
MO-capture make install

# 4. Verificar instalación
MO-capture status
find /usr/local -name "*app*"
📊 Formatos y Estructuras
Estructura de Template JSON
json
{
  "MO_template": {
    "version": "2.1",
    "system": "Devuan13-LXC",
    "timestamp": "2025-11-17T20:33:01+00:00",
    "command": "apt-get",
    "arguments": "install -y nginx",
    "snapshots": {
      "pre": "MO-snap-20251117-203300-622",
      "post": "MO-snap-20251117-203301-100"
    },
    "generator": "MO-capture"
  },
  "operations": {
    "files_created": [
      {
        "path": "/usr/sbin/nginx",
        "size": 1024000,
        "permissions": "755",
        "hash": "abc123def456...",
        "owner": "0:0",
        "modified": 1731877981
      }
    ],
    "directories_created": [
      "/etc/nginx",
      "/var/log/nginx"
    ],
    "permissions_changed": [
      "/usr/sbin/nginx"
    ]
  },
  "summary": {
    "total_files_created": 15,
    "total_directories_created": 3,
    "total_permissions_changed": 2
  },
  "metadata": {
    "strace_log": "/tmp/MO-strace-12345.log",
    "analysis_method": "strace_and_snapshot",
    "template_version": "2.1"
  }
}
Estructura de Snapshots
Cada snapshot contiene:

text
MO-snap-YYYYMMDD-HHMMSS-SSS/
├── files.txt          # find /usr/local /etc /opt -type f
├── packages.txt       # dpkg -l
└── services.txt       # systemctl list-unit-files
Configuración del Sistema (/etc/MO-capture/config.yaml)
yaml
version: "2.1"
system: "Devuan13-LXC"

# Directorios monitoreados
capture_directories:
  - /usr/local
  - /etc
  - /opt
  - /var/lib

# Patrones ignorados
ignore_patterns:
  - "*.log"
  - "*.tmp"
  - "*.cache"
  - "/tmp/*"
  - "/var/tmp/*"
  - "/dev/*"

# Comandos interceptados
intercepted_commands:
  - apt-get
  - apt
  - dpkg
  - make
  - pip
  - pip3

# Configuración de logging
logging:
  level: "INFO"
  file: "/var/log/MO-capture.log"
  max_size: "10MB"

# Configuración de snapshots
snapshots:
  max_count: 50
  auto_cleanup: true
⚙️ Mecanismos Internos
Sistema de Interceptación
MO-capture utiliza múltiples estrategias para capturar instalaciones:

bash
# 1. Wrapper de comandos
alias apt-get="MO-capture apt-get"
alias make="MO-capture make"

# 2. Interceptación con strace
strace -f -e trace=file,chmod,chown -o /tmp/MO-strace-$$.log <comando>

# 3. Análisis de syscalls
#    - open, openat (creación de archivos)
#    - chmod, fchmod (cambios de permisos)
#    - mkdir (creación de directorios)
Sistema de Snapshots
python
# Algoritmo de creación de snapshots
def create_snapshot(name):
    snapshot_id = f"MO-snap-{timestamp_con_milisegundos}"
    
    # Capturar estado del sistema de archivos
    files = find(capture_directories).limit(1000)
    
    # Capturar estado de paquetes
    packages = dpkg_list()
    
    # Capturar estado de servicios
    services = systemctl_list_unit_files()
    
    return snapshot_id
Generación de Templates
python
# Proceso de generación de templates
def generate_template(pre_snapshot, post_snapshot, command):
    # Comparar snapshots
    differences = compare_snapshots(pre_snapshot, post_snapshot)
    
    # Analizar log de strace
    file_operations = parse_strace_log(strace_log)
    
    # Combinar información
    template = {
        "metadata": build_metadata(command),
        "operations": merge_operations(differences, file_operations),
        "summary": calculate_summary()
    }
    
    return template
🛠️ Mantenimiento
Tareas de Mantenimiento Regular
bash
# Limpieza de archivos temporales
MO-capture cleanup

# Verificación de integridad
MO-capture status
ls -la /var/lib/MO-capture/snapshots | wc -l
ls -la /var/lib/MO-capture/templates | wc -l

# Rotación de logs (si se implementa)
logrotate /etc/logrotate.d/mo-capture
Backup del Sistema
bash
# Backup completo del sistema MO-capture
/root/mo-capture-backup.sh

# El backup genera:
# - mo-system-YYYYMMDD-HHMMSS.tar.gz
# - Contiene todos los componentes del sistema
# - Script de restauración incluido
Monitoreo de Recursos
bash
# Ver uso de disco
du -sh /var/lib/MO-capture/

# Ver logs recientes
tail -20 /var/log/MO-capture.log

# Ver estado de servicios relacionados
systemctl status systemd-journald  # Para strace
🐛 Solución de Problemas
Problemas Comunes y Soluciones
Error: "Comando no encontrado"
bash
# Verificar que el comando existe
which <comando>

# Usar ruta completa
MO-capture /usr/bin/make install
Error: "Permiso denegado"
bash
# Ejecutar con privilegios necesarios
sudo MO-capture apt-get install -y <paquete>
Snapshots con el mismo ID
bash
# Esto es normal en instalaciones rápidas
# MO-capture v2.1+ usa milisegundos para diferenciar
MO-snap-20251117-203300-622
MO-snap-20251117-203301-100
Logs de Strace muy grandes
bash
# Configurar límites en config.yaml
strace:
  max_log_size: "10MB"
  trace_patterns: ["file", "chmod", "chown"]
Diagnóstico Avanzado
bash
# Modo verbose temporal
MO-capture --debug apt-get install -y <paquete>

# Ver logs en tiempo real
tail -f /var/log/MO-capture.log

# Probar componente específico
python3 /usr/local/lib/MO-capture/template-generator.py --help

# Verificar permisos
ls -la /usr/local/bin/MO-* /var/lib/MO-capture/
Reset Completo del Sistema
bash
# En caso de corrupción o problemas graves
MO-capture reset
rm -f /var/log/MO-capture.log
systemctl daemon-reload  # Si se usan servicios
🔮 Características Futuras (Roadmap)
Próximas Versiones
v2.2: Análisis de archivos de configuración integrado

v3.0: Base de datos SQLite para tracking

v3.1: Sistema de rollback desde templates

v3.5: Interfaz web de gestión

v4.0: Soporte multi-plataforma

Extensiones Planeadas
bash
# Análisis de configuraciones
MO-analyze-config /etc/nginx/nginx.conf

# Gestión de dependencias
MO-capture --with-dependencies apt-get install <paquete>

# Exportación a otros formatos
MO-capture --export dockerfile <template.json>
MO-capture v2.1 - Sistema estable y listo para producción en entornos Devuan/Debian. Documentación completa y mecanismos de respaldo garantizan la confiabilidad del sistema.

