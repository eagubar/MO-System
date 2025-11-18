#!/usr/bin/env python3
"""
MO-capture Template Generator v1.1
Genera templates JSON a partir de logs de strace
"""

import json
import os
import hashlib
import argparse
import subprocess
from pathlib import Path
from datetime import datetime

class MOTemplateGenerator:
    def __init__(self):
        self.config = {
            "capture_dirs": ["/usr/local", "/etc", "/opt", "/var/lib"],
            "ignore_patterns": ["*.log", "*.tmp", "*.cache", "/tmp/*", "/var/tmp/*", "/proc/*", "/sys/*"],
            "system_info": "Devuan13-LXC"
        }
        
    def analyze_installation(self, strace_log, command, pre_snapshot=None, post_snapshot=None):
        """Analiza la instalación completa"""
        strace_ops = self.analyze_strace_log(strace_log, command)
        snapshot_ops = self.analyze_snapshots(pre_snapshot, post_snapshot) if pre_snapshot and post_snapshot else {}
        
        # Combinar operaciones
        all_operations = {
            "files_created": list(set(strace_ops.get("files_created", []) + snapshot_ops.get("files_created", []))),
            "directories_created": list(set(strace_ops.get("directories_created", []) + snapshot_ops.get("directories_created", []))),
            "permissions_changed": list(set(strace_ops.get("permissions_changed", []) + snapshot_ops.get("permissions_changed", [])))
        }
        
        return self.generate_mo_template(all_operations, command)
    
    def analyze_strace_log(self, log_file, command):
        """Analiza log de strace para detectar cambios"""
        operations = {
            "files_created": [],
            "directories_created": [],
            "permissions_changed": []
        }
        
        if not os.path.exists(log_file):
            return operations
            
        try:
            with open(log_file, 'r', errors='ignore') as f:
                for line in f:
                    self.parse_strace_line(line, operations)
        except Exception as e:
            print(f"MO-capture: Error analizando strace: {e}")
        
        return operations
    
    def analyze_snapshots(self, pre_snapshot, post_snapshot):
        """Compara snapshots para detectar cambios"""
        operations = {
            "files_created": [],
            "directories_created": []
        }
        
        if not os.path.exists(pre_snapshot) or not os.path.exists(post_snapshot):
            return operations
            
        try:
            # Leer archivos de los snapshots
            with open(pre_snapshot, 'r') as f:
                pre_files = set(f.read().splitlines())
            with open(post_snapshot, 'r') as f:
                post_files = set(f.read().splitlines())
            
            # Encontrar archivos nuevos
            new_files = post_files - pre_files
            for file_path in new_files:
                if self.should_capture(file_path):
                    file_info = self.get_file_info(file_path)
                    if file_info:
                        operations["files_created"].append(file_info)
                        
        except Exception as e:
            print(f"MO-capture: Error analizando snapshots: {e}")
        
        return operations
    
    def parse_strace_line(self, line, operations):
        """Parse una línea de strace"""
        line = line.strip()
        
        # Detectar archivos creados (open con O_CREAT)
        if 'open' in line and 'O_CREAT' in line:
            file_path = self.extract_file_path(line)
            if file_path and self.should_capture(file_path) and not os.path.isdir(file_path):
                file_info = self.get_file_info(file_path)
                if file_info:
                    operations["files_created"].append(file_info)
        
        # Detectar directorios creados (mkdir)
        elif 'mkdir' in line:
            dir_path = self.extract_file_path(line)
            if dir_path and self.should_capture(dir_path):
                operations["directories_created"].append(dir_path)
        
        # Detectar cambios de permisos
        elif 'chmod' in line:
            file_path = self.extract_file_path(line)
            if file_path and self.should_capture(file_path):
                operations["permissions_changed"].append(file_path)
    
    def extract_file_path(self, line):
        """Extrae ruta de archivo de línea strace"""
        try:
            # Buscar patrones comunes
            if '\"' in line:
                parts = line.split('\"')
                if len(parts) >= 2:
                    path = parts[1]
                    if path and not path.isspace() and not path.startswith('/proc'):
                        return path
        except:
            pass
        return None
    
    def should_capture(self, path):
        """Determina si un path debe ser capturado"""
        if not path or not isinstance(path, str):
            return False
            
        ignore_patterns = self.config["ignore_patterns"]
        capture_dirs = self.config["capture_dirs"]
        
        # Verificar directorios de captura
        in_capture_dir = any(path.startswith(dir) for dir in capture_dirs)
        if not in_capture_dir:
            return False
        
        # Verificar patrones ignorados
        for pattern in ignore_patterns:
            if pattern.startswith('*'):
                if Path(path).match(pattern):
                    return False
            elif path.startswith(pattern.rstrip('*')):
                return False
        
        return True
    
    def get_file_info(self, file_path):
        """Obtiene información de un archivo"""
        try:
            if not os.path.exists(file_path):
                return None
                
            stat = os.stat(file_path)
            
            # Información básica del archivo
            file_info = {
                "path": file_path,
                "size": stat.st_size,
                "permissions": oct(stat.st_mode)[-3:],
                "owner": f"{stat.st_uid}:{stat.st_gid}",
                "modified": stat.st_mtime
            }
            
            # Hash para archivos pequeños
            if 0 < stat.st_size < 102400:  # 100KB max
                try:
                    with open(file_path, 'rb') as f:
                        content = f.read()
                        file_info["hash"] = hashlib.sha256(content).hexdigest()[:16]
                except (IOError, OSError):
                    file_info["hash"] = "unreadable"
            else:
                file_info["hash"] = "too_large"
            
            return file_info
        except (OSError, IOError) as e:
            return None
    
    def generate_mo_template(self, operations, command):
        """Genera template MO en formato JSON"""
        template = {
            "MO_template": {
                "version": "1.1",
                "system": self.config["system_info"],
                "timestamp": datetime.now().isoformat(),
                "command": command,
                "generator": "MO-capture"
            },
            "operations": operations,
            "summary": {
                "total_files_created": len(operations["files_created"]),
                "total_directories_created": len(operations["directories_created"]),
                "total_permissions_changed": len(operations["permissions_changed"])
            },
            "metadata": {
                "analysis_method": "strace_and_snapshot",
                "template_version": "1.1"
            }
        }
        
        return template

def main():
    parser = argparse.ArgumentParser(description="MO-capture Template Generator v1.1")
    parser.add_argument("--strace-log", required=True, help="Strace log file")
    parser.add_argument("--command", required=True, help="Command executed")
    parser.add_argument("--output", required=True, help="Output template file")
    parser.add_argument("--pre-snapshot", help="Pre-installation snapshot file")
    parser.add_argument("--post-snapshot", help="Post-installation snapshot file")
    
    args = parser.parse_args()
    
    generator = MOTemplateGenerator()
    
    # Analizar instalación
    template = generator.analyze_installation(
        args.strace_log, 
        args.command, 
        args.pre_snapshot, 
        args.post_snapshot
    )
    
    # Guardar template
    with open(args.output, 'w') as f:
        json.dump(template, f, indent=2, ensure_ascii=False)
    
    print(f"MO-capture: Template generado: {args.output}")
    print(f"MO-capture: Resumen - {template['summary']}")

if __name__ == "__main__":
    main()
