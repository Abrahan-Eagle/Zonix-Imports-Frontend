#!/bin/bash

# Script para corregir errores de sintaxis específicos
# ZONIX-IMPORTS Frontend - Corrección de sintaxis v2

echo "🔧 Corrigiendo errores de sintaxis específicos..."
echo "==============================================="

# Función para corregir sintaxis específica
fix_specific_syntax() {
    local file="$1"
    echo "📝 Corrigiendo: $file"
    
    # Reemplazar ${$(...)} con la sintaxis correcta
    sed -i 's/\${$((const bool\.fromEnvironment("dart\.vm\.product") ? (dotenv\.env\["API_URL_PROD"\] ?? "https:\/\/zonix\.uniblockweb\.com") : (dotenv\.env\["API_URL_LOCAL"\] ?? "http:\/\/192\.168\.0\.101:8000")))}/\${const bool.fromEnvironment("dart.vm.product") ? (dotenv.env["API_URL_PROD"] ?? "https:\/\/zonix.uniblockweb.com") : (dotenv.env["API_URL_LOCAL"] ?? "http:\/\/192.168.0.101:8000")}/g' "$file"
    
    # Reemplazar ${$(...)} con la sintaxis correcta para WS URLs
    sed -i 's/\${$((const bool\.fromEnvironment("dart\.vm\.product") ? (dotenv\.env\["WS_URL_PROD"\] ?? "wss:\/\/zonix\.uniblockweb\.com") : (dotenv\.env\["WS_URL_LOCAL"\] ?? "ws:\/\/192\.168\.0\.101:6001")))}/\${const bool.fromEnvironment("dart.vm.product") ? (dotenv.env["WS_URL_PROD"] ?? "wss:\/\/zonix.uniblockweb.com") : (dotenv.env["WS_URL_LOCAL"] ?? "ws:\/\/192.168.0.101:6001")}/g' "$file"
}

# Procesar todos los archivos con errores de sintaxis
echo "📁 Procesando archivos..."

for file in $(find lib -name "*.dart" -exec grep -l "\$(" {} \;); do
    fix_specific_syntax "$file"
done

echo "✅ Corrección de sintaxis específica completada!"
echo "📋 Archivos procesados:"
find lib -name "*.dart" -exec grep -l "\$(" {} \; 2>/dev/null || echo "No se encontraron más errores de sintaxis"

echo ""
echo "🔧 Próximos pasos:"
echo "1. Probar la aplicación"
echo "2. Verificar que compile correctamente"
