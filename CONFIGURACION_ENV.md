# 🔧 CONFIGURACIÓN CON VARIABLES DE ENTORNO (.env)

## 📋 Descripción

El sistema ZONIX-IMPORTS ahora utiliza **exclusivamente** el archivo `.env` para toda la configuración, eliminando la dependencia de valores hardcodeados en `app_config.dart`.

---

## 🚀 Configuración Inicial

### 1. Crear archivo .env
```bash
# Copiar el archivo de ejemplo
cp .env.example .env
```

### 2. Configurar variables
Edita el archivo `.env` con tus valores específicos:

```env
# API URLs
API_URL_LOCAL=http://192.168.0.101:8000
API_URL_PROD=https://zonix.uniblockweb.com

# WebSocket Configuration
WS_URL_LOCAL=ws://192.168.0.101:6001
WS_URL_PROD=wss://zonix.uniblockweb.com

# Echo Server
ECHO_APP_ID=zonix-eats-app
ECHO_KEY=zonix-eats-key
ENABLE_WEBSOCKETS=true

# Google Maps
GOOGLE_MAPS_API_KEY=tu_api_key_aqui

# Firebase
FIREBASE_PROJECT_ID=tu_proyecto_id
FIREBASE_MESSAGING_SENDER_ID=tu_sender_id
FIREBASE_APP_ID=tu_app_id

# Aplicación
APP_NAME=ZONIX-IMPORTS
APP_VERSION=1.0.0
APP_BUILD_NUMBER=1

# Paginación
DEFAULT_PAGE_SIZE=20
MAX_PAGE_SIZE=100

# Timeouts (milisegundos)
CONNECTION_TIMEOUT=30000
RECEIVE_TIMEOUT=30000
REQUEST_TIMEOUT=30000

# Reintentos
MAX_RETRY_ATTEMPTS=3
RETRY_DELAY_MS=1000

# Desarrollo
DEBUG_MODE=true
LOG_LEVEL=debug
```

---

## 🔧 Uso en el Código

### Acceder a configuraciones
```dart
import 'package:zonix/config/app_config.dart';

// URLs
String apiUrl = AppConfig.apiUrl;
String wsUrl = AppConfig.wsUrl;

// Configuración de aplicación
String appName = AppConfig.appName;
String version = AppConfig.appVersion;

// Timeouts
int timeout = AppConfig.connectionTimeout;

// Configuración booleana
bool debugMode = AppConfig.debugMode;
```

### Inicialización
El archivo `.env` se carga automáticamente en `main.dart`:

```dart
Future<void> main() async {
  // ... otras inicializaciones
  
  // Inicializar configuración desde .env
  await AppConfig.initialize();
  
  // ... resto del código
}
```

---

## 📁 Estructura de Archivos

```
lib/
├── config/
│   └── app_config.dart          # Clase que lee desde .env
├── main.dart                    # Inicializa AppConfig
.env                             # Variables de entorno (NO en git)
.env.example                     # Plantilla de configuración
```

---

## ⚠️ Importante

### Seguridad
- **NUNCA** subas el archivo `.env` al repositorio
- El archivo `.env` está en `.gitignore`
- Usa `.env.example` como plantilla

### Valores por Defecto
Si una variable no existe en `.env`, se usan valores por defecto:
- API URLs: URLs de desarrollo
- Timeouts: 30 segundos
- Paginación: 20 elementos por página
- Debug: habilitado

### Entornos
- **Desarrollo**: Usa `API_URL_LOCAL` y `WS_URL_LOCAL`
- **Producción**: Usa `API_URL_PROD` y `WS_URL_PROD`

---

## 🔄 Migración Completada

✅ **Eliminado**: Valores hardcodeados en `app_config.dart`  
✅ **Agregado**: Lectura dinámica desde `.env`  
✅ **Mantenido**: Misma interfaz de acceso  
✅ **Mejorado**: Configuración centralizada y segura  

---

## 🎯 Beneficios

1. **Seguridad**: Variables sensibles fuera del código
2. **Flexibilidad**: Cambiar configuración sin recompilar
3. **Entornos**: Diferentes configuraciones por ambiente
4. **Mantenimiento**: Configuración centralizada
5. **Colaboración**: Plantilla clara para nuevos desarrolladores
