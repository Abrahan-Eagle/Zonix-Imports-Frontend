# 📱 ZONIX - Sistema de Gestión de Gas Doméstico

## 🎯 Descripción

**ZONIX** es un sistema integral de gestión de distribución de gas doméstico que controla el flujo completo desde la solicitud hasta la entrega de bombonas de gas, implementando reglas estrictas de control y distribución.

## 🏗️ Arquitectura

- **Frontend**: Flutter 3.35.2 (Dart 3.9.0) - Aplicación móvil
- **Backend**: Laravel 10 (PHP 8.1+) - API REST
- **Base de Datos**: MySQL
- **Autenticación**: Google Sign-In + Laravel Sanctum
- **Dispositivo**: Android 192.168.27.10:5555

## 🏭 Modelo de Negocio

### 🎫 Sistema de Tickets
- **Regla de 21 días** entre compras para usuarios internos
- **Solo domingos** para usuarios externos
- **Límite diario**: 200 tickets por estación
- **Cola virtual** con posiciones automáticas
- **QR Code** único por ticket

### 🏪 Estaciones de Gas
- **12 estaciones** en Carabobo, Valencia, Guacara
- **Horarios específicos** por día de la semana
- **Geolocalización** con coordenadas GPS
- **Responsables asignados** por estación

### 👥 Roles de Usuario
1. **Usuario Regular**: Crear tickets, ver historial
2. **Sales Admin**: Verificar datos, escanear QR, aprobar tickets
3. **Dispatcher**: Gestionar colas, despachar tickets

## 🔄 Flujo de Trabajo

1. **Usuario crea ticket** → Selecciona bombona → Asigna estación
2. **Sistema valida** → Reglas de negocio → Asigna posición en cola
3. **Sales Admin verifica** → Escanea QR → Valida datos
4. **Dispatcher gestiona** → Cola física → Entrega bombona
5. **Ticket marcado** → `dispatched` → Registro completo

## 🚀 Funcionalidades

- ✅ **Autenticación Google** con roles y permisos
- ✅ **Gestión completa de perfiles** con datos personales
- ✅ **Sistema de tickets** con reglas de negocio
- ✅ **Verificación de datos** por Sales Admin
- ✅ **Despacho de tickets** por Dispatcher
- ✅ **Refresh automático** cada 30 segundos
- ✅ **Formato correcto** de números de teléfono
- ✅ **Gestión de imágenes** en producción

## 📊 Estado del Proyecto

- ✅ **Frontend**: Funcionando correctamente
- ✅ **Backend**: API estable y optimizada
- ✅ **Base de datos**: Configurada y funcionando
- ✅ **Autenticación**: Google Sign-In operativo
- ✅ **Despliegue**: Automatizado en producción

## 🎯 Roadmap MVP

### 🔥 **MVP Mínimo (Crítico)**
- [ ] **Notificaciones Push** - Alertas en tiempo real
- [ ] **Sistema de Pagos** - Integración con pasarelas
- [ ] **Dashboard Básico** - Métricas de negocio

### ⚡ **MVP Completo (Importante)**
- [ ] **Emails Automáticos** - Comunicación con usuarios
- [ ] **Búsqueda y Filtros** - Gestión eficiente de datos
- [ ] **Geolocalización** - Optimización de rutas

### 📈 **Post-MVP (Escalable)**
- [ ] **Funcionalidades Offline** - Sincronización local
- [ ] **Seguridad Avanzada** - Protección robusta
- [ ] **Gestión de Inventario** - Control de stock
- [ ] **Panel de Administración** - Gestión centralizada

## 🔧 Comandos Rápidos

### Frontend
```bash
# Desarrollo
flutter run -d 192.168.27.10:5555

# Producción
flutter run --release -d 192.168.27.10:5555
```

### Backend
```bash
# Servidor local
php artisan serve --host=192.168.27.4 --port=8000

# Limpiar cache
php artisan config:cache
```

## 📖 Documentación Completa

Para información detallada sobre el modelo de negocio, flujo de trabajo, API endpoints, configuración y recomendaciones completas de MVP, consulta el archivo [README_ZONIX_COMPLETE.md](README_ZONIX_COMPLETE.md).

## 🎯 Conclusión

ZONIX implementa un modelo de negocio sólido para la distribución controlada de gas doméstico con eficiencia, seguridad y transparencia total del proceso.

**Para convertirse en un MVP completo y escalable, se requiere la implementación de los componentes críticos identificados en el roadmap.**

---

**Versión**: 1.0.0+1 | **Última actualización**: Diciembre 2024
