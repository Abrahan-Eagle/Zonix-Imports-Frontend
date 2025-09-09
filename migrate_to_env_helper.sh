#!/bin/bash

# Script para migrar de AppConfig a EnvHelper
# ZONIX-IMPORTS Frontend - Migración a EnvHelper

echo "🚀 Migrando de AppConfig a EnvHelper..."
echo "====================================="

# Función para reemplazar AppConfig con EnvHelper
replace_with_env_helper() {
    local file="$1"
    echo "📝 Procesando: $file"
    
    # Reemplazar AppConfig.apiUrl con EnvHelper.apiUrl
    sed -i 's/AppConfig\.apiUrl/EnvHelper.apiUrl/g' "$file"
    
    # Reemplazar AppConfig.requestTimeout con EnvHelper.requestTimeout
    sed -i 's/AppConfig\.requestTimeout/EnvHelper.requestTimeout/g' "$file"
    
    # Reemplazar AppConfig.connectionTimeout con EnvHelper.connectionTimeout
    sed -i 's/AppConfig\.connectionTimeout/EnvHelper.connectionTimeout/g' "$file"
    
    # Reemplazar AppConfig.receiveTimeout con EnvHelper.receiveTimeout
    sed -i 's/AppConfig\.receiveTimeout/EnvHelper.receiveTimeout/g' "$file"
    
    # Reemplazar AppConfig.wsUrl con EnvHelper.wsUrl
    sed -i 's/AppConfig\.wsUrl/EnvHelper.wsUrl/g' "$file"
    
    # Reemplazar AppConfig.echoAppId con EnvHelper.echoAppId
    sed -i 's/AppConfig\.echoAppId/EnvHelper.echoAppId/g' "$file"
    
    # Reemplazar AppConfig.echoKey con EnvHelper.echoKey
    sed -i 's/AppConfig\.echoKey/EnvHelper.echoKey/g' "$file"
    
    # Reemplazar AppConfig.enableWebsockets con EnvHelper.enableWebsockets
    sed -i 's/AppConfig\.enableWebsockets/EnvHelper.enableWebsockets/g' "$file"
    
    # Reemplazar AppConfig.googleMapsApiKey con EnvHelper.googleMapsApiKey
    sed -i 's/AppConfig\.googleMapsApiKey/EnvHelper.googleMapsApiKey/g' "$file"
    
    # Reemplazar AppConfig.firebaseProjectId con EnvHelper.firebaseProjectId
    sed -i 's/AppConfig\.firebaseProjectId/EnvHelper.firebaseProjectId/g' "$file"
    
    # Reemplazar AppConfig.firebaseMessagingSenderId con EnvHelper.firebaseMessagingSenderId
    sed -i 's/AppConfig\.firebaseMessagingSenderId/EnvHelper.firebaseMessagingSenderId/g' "$file"
    
    # Reemplazar AppConfig.firebaseAppId con EnvHelper.firebaseAppId
    sed -i 's/AppConfig\.firebaseAppId/EnvHelper.firebaseAppId/g' "$file"
    
    # Reemplazar AppConfig.appName con EnvHelper.appName
    sed -i 's/AppConfig\.appName/EnvHelper.appName/g' "$file"
    
    # Reemplazar AppConfig.appVersion con EnvHelper.appVersion
    sed -i 's/AppConfig\.appVersion/EnvHelper.appVersion/g' "$file"
    
    # Reemplazar AppConfig.appBuildNumber con EnvHelper.appBuildNumber
    sed -i 's/AppConfig\.appBuildNumber/EnvHelper.appBuildNumber/g' "$file"
    
    # Reemplazar AppConfig.defaultPageSize con EnvHelper.defaultPageSize
    sed -i 's/AppConfig\.defaultPageSize/EnvHelper.defaultPageSize/g' "$file"
    
    # Reemplazar AppConfig.maxPageSize con EnvHelper.maxPageSize
    sed -i 's/AppConfig\.maxPageSize/EnvHelper.maxPageSize/g' "$file"
    
    # Reemplazar AppConfig.maxRetryAttempts con EnvHelper.maxRetryAttempts
    sed -i 's/AppConfig\.maxRetryAttempts/EnvHelper.maxRetryAttempts/g' "$file"
    
    # Reemplazar AppConfig.retryDelayMs con EnvHelper.retryDelayMs
    sed -i 's/AppConfig\.retryDelayMs/EnvHelper.retryDelayMs/g' "$file"
    
    # Reemplazar AppConfig.debugMode con EnvHelper.debugMode
    sed -i 's/AppConfig\.debugMode/EnvHelper.debugMode/g' "$file"
    
    # Reemplazar AppConfig.logLevel con EnvHelper.logLevel
    sed -i 's/AppConfig\.logLevel/EnvHelper.logLevel/g' "$file"
    
    # Reemplazar import de app_config.dart con env_helper.dart
    sed -i 's/import.*app_config\.dart/import '\''package:zonix\/helpers\/env_helper.dart'\'';/g' "$file"
}

# Procesar todos los archivos que usan AppConfig
echo "📁 Procesando archivos..."

for file in $(find lib -name "*.dart" -exec grep -l "AppConfig\." {} \;); do
    replace_with_env_helper "$file"
done

echo "✅ Migración a EnvHelper completada!"
echo "📋 Archivos procesados:"
find lib -name "*.dart" -exec grep -l "AppConfig\." {} \; 2>/dev/null || echo "No se encontraron más referencias a AppConfig"

echo ""
echo "🔧 Próximos pasos:"
echo "1. Probar la aplicación"
echo "2. Eliminar el archivo app_config.dart"
echo "3. Hacer commit de los cambios"
