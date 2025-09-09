# 📱 REGLAS DE COMPILACIÓN - SOLO ANDROID

## 🚫 PROHIBIDO ABSOLUTAMENTE

- ❌ **NO compilar para Chrome (web)**
- ❌ **NO compilar para Linux (desktop)**  
- ❌ **NO usar emuladores**
- ❌ **NO usar `flutter run` sin especificar dispositivo**

## ✅ DISPOSITIVOS PERMITIDOS

- ✅ **Solo dispositivos Android físicos**
- ✅ **IP fija: 192.168.27.10:5555**
- ✅ **Conexión por red ADB o USB**

## 🚀 COMANDOS DE COMPILACIÓN

### Desarrollo
```bash
flutter run -d 192.168.27.10:5555
```

### Producción (Release)
```bash
flutter run --release -d 192.168.27.10:5555
```

### Scripts Automatizados
```bash
# Desarrollo
./run_android.sh

# Producción
./run_android_release.sh
```

## 🔧 VERIFICACIÓN DE DISPOSITIVO

### Verificar dispositivos conectados
```bash
adb devices
```

### Conectar por red
```bash
adb connect 192.168.27.10:5555
```

### Verificar dispositivos Flutter
```bash
flutter devices
```

## ⚙️ CONFIGURACIÓN REQUERIDA

### Dispositivo Android
- ✅ Depuración USB habilitada
- ✅ IP estática: 192.168.27.10
- ✅ Puerto 5555 abierto para ADB
- ✅ Conectado a la misma red

### Flutter
- ✅ Flutter configurado para Android
- ✅ Android SDK instalado
- ✅ ADB disponible

## 🔍 DIAGNÓSTICO DE PROBLEMAS

### Si no se puede conectar:
1. **Verificar que el dispositivo esté encendido**
2. **Habilitar 'Depuración USB' en el dispositivo**
3. **Verificar que la IP 192.168.27.10 sea correcta**
4. **Verificar que el puerto 5555 esté abierto**
5. **Conectar por USB primero: `adb tcpip 5555`**

### Comandos de diagnóstico:
```bash
# Verificar ADB
adb devices

# Conectar por red
adb connect 192.168.27.10:5555

# Verificar Flutter
flutter devices

# Verificar configuración Android
flutter doctor
```

## 📋 FLUJO DE TRABAJO

1. **Conectar dispositivo Android** con IP 192.168.27.10:5555
2. **Verificar conexión** con `adb devices`
3. **Ejecutar aplicación** con `./run_android.sh` o `flutter run -d 192.168.27.10:5555`
4. **Para release** usar `./run_android_release.sh` o `flutter run --release -d 192.168.27.10:5555`

## ⚠️ IMPORTANTE

- **Solo usar dispositivos Android físicos**
- **No usar Chrome, Linux o emuladores**
- **Siempre especificar el dispositivo con `-d 192.168.27.10:5555`**
- **Verificar conexión antes de compilar**
