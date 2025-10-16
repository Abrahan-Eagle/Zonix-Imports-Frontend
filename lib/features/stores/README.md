# 🏪 Módulo de Tiendas/Comercios

## 📋 Descripción

Módulo completo para visualizar y gestionar tiendas en la aplicación Zonix Imports.

## ✅ Backend (Completado)

### Endpoints Implementados:

**Públicos:**
- `GET /api/commerces` - Listar tiendas
- `GET /api/commerces/{id}` - Ver detalles de tienda
- `GET /api/commerces/{id}/products` - Productos de tienda
- `GET /api/business-types` - Tipos de negocio

**Autenticados (Vendedor):**
- `GET /api/my-commerce` - Mi tienda
- `PUT /api/my-commerce/toggle` - Abrir/cerrar tienda

### Filtros disponibles:
- ✅ Por estado (abierta/cerrada)
- ✅ Por tipo de negocio
- ✅ Búsqueda por nombre
- ✅ Ordenamiento
- ✅ Paginación

## ✅ Frontend (Estructura Creada)

### Archivos Implementados:

```
lib/features/stores/
├── data/
│   ├── models/
│   │   └── store_model.dart ✅
│   ├── datasources/
│   │   └── store_api_service.dart ✅
│   └── repositories/ (vacío)
├── domain/
│   ├── entities/ (vacío)
│   └── usecases/ (vacío)
└── presentation/
    ├── providers/
    │   └── store_provider.dart ✅
    ├── screens/ (POR CREAR)
    │   ├── stores_list_page.dart
    │   ├── store_detail_page.dart
    │   └── store_products_page.dart
    └── widgets/ (POR CREAR)
        ├── store_card.dart
        ├── store_filters.dart
        └── store_header.dart
```

## 🎯 Pantallas a Crear

### 1. **stores_list_page.dart**
Lista de todas las tiendas con:
- Grid/List de tiendas
- Búsqueda
- Filtros (abierta, tipo)
- Paginación infinita

### 2. **store_detail_page.dart**
Detalles de una tienda con:
- Información del negocio
- Estadísticas
- Métodos de pago aceptados
- Horario
- Botón "Ver Productos"
- Botón WhatsApp (opcional)

### 3. **store_products_page.dart**
Productos de la tienda:
- Grid de productos
- Usa ProductCard existente
- Filtros por categoría/modalidad
- Búsqueda en tienda

## 🔧 Widgets a Crear

### 1. **store_card.dart**
```dart
class StoreCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;
  
  // Mostrar:
  // - Logo/imagen
  // - Nombre
  // - Estado (abierta/cerrada)
  // - Tipo de negocio
  // - # de productos
  // - Badge de verificada
}
```

### 2. **store_filters.dart**
```dart
class StoreFilters extends StatelessWidget {
  // Filtros:
  // - Switch: Solo abiertas
  // - Dropdown: Tipo de negocio
  // - Ordenar por (nombre, productos)
}
```

### 3. **store_header.dart**
```dart
class StoreHeader extends StatelessWidget {
  final StoreModel store;
  
  // Mostrar:
  // - Banner/Cover
  // - Logo
  // - Nombre y tipo
  // - Estado
  // - Botones (compartir, WhatsApp)
}
```

## 📱 Integración en Main

Agregar en `main.dart`:

```dart
// En el Provider list
ChangeNotifierProvider(create: (_) => StoreProvider()),

// En el BottomNavigationBar nivel 0 (Comprador)
case 4: // Nuevo tab
  return const StoresListPage();
```

O agregar en el Drawer/Menu lateral.

## 🎨 Diseño Sugerido

### Colores:
- Verde para "Abierta" 🟢
- Rojo para "Cerrada" 🔴
- Azul para verificada ✓

### Iconos:
- `Icons.storefront` - Tiendas
- `Icons.verified` - Verificada
- `Icons.schedule` - Horario
- `Icons.payment` - Métodos de pago

## 🚀 Siguiente Paso

1. Crear `stores_list_page.dart`
2. Crear `store_card.dart`
3. Probar listado de tiendas
4. Crear `store_detail_page.dart`
5. Navegar de lista a detalle
6. Crear `store_products_page.dart`

## 📝 Notas

- El provider ya está listo
- El API service está completo
- Falta crear las pantallas visuales
- Usa componentes compartidos cuando sea posible (ProductCard, SearchBar, etc.)

