#!/bin/bash

# Script para migrar de AppConfig a dotenv.env directamente
# ZONIX-IMPORTS Frontend - Migración completa a .env

echo "🚀 Migrando de AppConfig a dotenv.env directamente..."
echo "=================================================="

# Función para reemplazar AppConfig.apiUrl
replace_api_url() {
    local file="$1"
    echo "📝 Procesando: $file"
    
    # Reemplazar AppConfig.apiUrl con lógica directa
    sed -i 's/AppConfig\.apiUrl/$(const bool.fromEnvironment("dart.vm.product") ? (dotenv.env["API_URL_PROD"] ?? "https:\/\/zonix.uniblockweb.com") : (dotenv.env["API_URL_LOCAL"] ?? "http:\/\/192.168.0.101:8000"))/g' "$file"
    
    # Reemplazar AppConfig.requestTimeout
    sed -i 's/AppConfig\.requestTimeout/int.tryParse(dotenv.env["REQUEST_TIMEOUT"] ?? "30000") ?? 30000/g' "$file"
    
    # Reemplazar AppConfig.connectionTimeout
    sed -i 's/AppConfig\.connectionTimeout/int.tryParse(dotenv.env["CONNECTION_TIMEOUT"] ?? "30000") ?? 30000/g' "$file"
    
    # Reemplazar AppConfig.receiveTimeout
    sed -i 's/AppConfig\.receiveTimeout/int.tryParse(dotenv.env["RECEIVE_TIMEOUT"] ?? "30000") ?? 30000/g' "$file"
    
    # Reemplazar AppConfig.wsUrl
    sed -i 's/AppConfig\.wsUrl/$(const bool.fromEnvironment("dart.vm.product") ? (dotenv.env["WS_URL_PROD"] ?? "wss:\/\/zonix.uniblockweb.com") : (dotenv.env["WS_URL_LOCAL"] ?? "ws:\/\/192.168.0.101:6001"))/g' "$file"
    
    # Reemplazar AppConfig.echoAppId
    sed -i 's/AppConfig\.echoAppId/dotenv.env["ECHO_APP_ID"] ?? "zonix-eats-app"/g' "$file"
    
    # Reemplazar AppConfig.echoKey
    sed -i 's/AppConfig\.echoKey/dotenv.env["ECHO_KEY"] ?? "zonix-eats-key"/g' "$file"
    
    # Reemplazar AppConfig.enableWebsockets
    sed -i 's/AppConfig\.enableWebsockets/(dotenv.env["ENABLE_WEBSOCKETS"] ?? "true").toLowerCase() == "true"/g' "$file"
    
    # Reemplazar AppConfig.googleMapsApiKey
    sed -i 's/AppConfig\.googleMapsApiKey/dotenv.env["GOOGLE_MAPS_API_KEY"] ?? "your_google_maps_api_key_here"/g' "$file"
    
    # Reemplazar AppConfig.firebaseProjectId
    sed -i 's/AppConfig\.firebaseProjectId/dotenv.env["FIREBASE_PROJECT_ID"] ?? "your_firebase_project_id"/g' "$file"
    
    # Reemplazar AppConfig.firebaseMessagingSenderId
    sed -i 's/AppConfig\.firebaseMessagingSenderId/dotenv.env["FIREBASE_MESSAGING_SENDER_ID"] ?? "your_sender_id"/g' "$file"
    
    # Reemplazar AppConfig.firebaseAppId
    sed -i 's/AppConfig\.firebaseAppId/dotenv.env["FIREBASE_APP_ID"] ?? "your_app_id"/g' "$file"
    
    # Reemplazar AppConfig.appName
    sed -i 's/AppConfig\.appName/dotenv.env["APP_NAME"] ?? "ZONIX-IMPORTS"/g' "$file"
    
    # Reemplazar AppConfig.appVersion
    sed -i 's/AppConfig\.appVersion/dotenv.env["APP_VERSION"] ?? "1.0.0"/g' "$file"
    
    # Reemplazar AppConfig.appBuildNumber
    sed -i 's/AppConfig\.appBuildNumber/dotenv.env["APP_BUILD_NUMBER"] ?? "1"/g' "$file"
    
    # Reemplazar AppConfig.defaultPageSize
    sed -i 's/AppConfig\.defaultPageSize/int.tryParse(dotenv.env["DEFAULT_PAGE_SIZE"] ?? "20") ?? 20/g' "$file"
    
    # Reemplazar AppConfig.maxPageSize
    sed -i 's/AppConfig\.maxPageSize/int.tryParse(dotenv.env["MAX_PAGE_SIZE"] ?? "100") ?? 100/g' "$file"
    
    # Reemplazar AppConfig.maxRetryAttempts
    sed -i 's/AppConfig\.maxRetryAttempts/int.tryParse(dotenv.env["MAX_RETRY_ATTEMPTS"] ?? "3") ?? 3/g' "$file"
    
    # Reemplazar AppConfig.retryDelayMs
    sed -i 's/AppConfig\.retryDelayMs/int.tryParse(dotenv.env["RETRY_DELAY_MS"] ?? "1000") ?? 1000/g' "$file"
    
    # Reemplazar AppConfig.debugMode
    sed -i 's/AppConfig\.debugMode/(dotenv.env["DEBUG_MODE"] ?? "true").toLowerCase() == "true"/g' "$file"
    
    # Reemplazar AppConfig.logLevel
    sed -i 's/AppConfig\.logLevel/dotenv.env["LOG_LEVEL"] ?? "debug"/g' "$file"
}

# Procesar todos los archivos que usan AppConfig
echo "📁 Procesando archivos..."

for file in $(find lib -name "*.dart" -exec grep -l "AppConfig\." {} \;); do
    replace_api_url "$file"
done

echo "✅ Migración completada!"
echo "📋 Archivos procesados:"
find lib -name "*.dart" -exec grep -l "AppConfig\." {} \; 2>/dev/null || echo "No se encontraron más referencias a AppConfig"

echo ""
echo "🔧 Próximos pasos:"
echo "1. Revisar los archivos modificados"
echo "2. Agregar import 'package:flutter_dotenv/flutter_dotenv.dart' donde sea necesario"
echo "3. Eliminar import '../../config/app_config.dart' de los archivos"
echo "4. Probar la aplicación"
echo "5. Eliminar el archivo app_config.dart"
