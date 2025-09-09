#!/bin/bash

# Script para limpiar imports de app_config.dart y agregar flutter_dotenv
# ZONIX-IMPORTS Frontend - Limpieza de imports

echo "🧹 Limpiando imports de app_config.dart..."
echo "========================================"

# Función para limpiar imports
clean_imports() {
    local file="$1"
    echo "📝 Limpiando: $file"
    
    # Eliminar líneas que importan app_config.dart
    sed -i '/import.*app_config\.dart/d' "$file"
    
    # Verificar si ya tiene flutter_dotenv
    if ! grep -q "import 'package:flutter_dotenv/flutter_dotenv.dart';" "$file"; then
        # Agregar import de flutter_dotenv después de los otros imports
        sed -i '/^import/a import '\''package:flutter_dotenv/flutter_dotenv.dart'\'';' "$file"
    fi
}

# Procesar todos los archivos que importan app_config.dart
echo "📁 Procesando archivos..."

for file in $(find lib -name "*.dart" -exec grep -l "app_config.dart" {} \;); do
    clean_imports "$file"
done

echo "✅ Limpieza completada!"
echo "📋 Archivos procesados:"
find lib -name "*.dart" -exec grep -l "app_config.dart" {} \; 2>/dev/null || echo "No se encontraron más imports de app_config.dart"

echo ""
echo "🔧 Próximos pasos:"
echo "1. Probar la aplicación"
echo "2. Eliminar el archivo app_config.dart"
echo "3. Hacer commit de los cambios"
