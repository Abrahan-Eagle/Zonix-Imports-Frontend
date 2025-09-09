#!/bin/bash

# Script para ejecutar Flutter en modo RELEASE solo en dispositivos Android
# ZONIX-Imports Frontend - Solo Android Release

echo "🚀 ZONIX-Imports - Ejecutando en Android (RELEASE)"
echo "================================================="

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado"
    exit 1
fi

# Verificar si ADB está instalado
if ! command -v adb &> /dev/null; then
    echo "❌ ADB no está instalado"
    exit 1
fi

# IP del dispositivo Android
DEVICE_IP="192.168.27.10:5555"

echo "📱 Verificando dispositivos conectados..."
adb devices

echo ""
echo "🔌 Intentando conectar al dispositivo Android en $DEVICE_IP..."

# Intentar conectar al dispositivo
adb connect $DEVICE_IP

# Esperar un momento para la conexión
sleep 2

# Verificar si la conexión fue exitosa
if adb devices | grep -q "$DEVICE_IP"; then
    echo "✅ Dispositivo Android conectado exitosamente"
    
    # Verificar dispositivos Flutter
    echo ""
    echo "🔍 Verificando dispositivos Flutter disponibles..."
    flutter devices
    
    echo ""
    echo "🚀 Ejecutando aplicación Flutter en Android (RELEASE MODE)..."
    
    # Ejecutar Flutter en modo release en el dispositivo Android
    flutter run --release -d $DEVICE_IP
else
    echo "❌ No se pudo conectar al dispositivo Android en $DEVICE_IP"
    echo ""
    echo "🔧 Pasos para solucionar:"
    echo "1. Verificar que el dispositivo Android esté encendido"
    echo "2. Habilitar 'Depuración USB' en el dispositivo"
    echo "3. Verificar que la IP $DEVICE_IP sea correcta"
    echo "4. Verificar que el puerto 5555 esté abierto"
    echo "5. Conectar por USB primero: adb tcpip 5555"
    echo ""
    echo "📋 Comandos de diagnóstico:"
    echo "   adb devices"
    echo "   adb connect $DEVICE_IP"
    echo "   flutter devices"
    exit 1
fi
