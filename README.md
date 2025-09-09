## Zonix Imports — Frontend (Flutter)

Aplicación móvil Flutter para el MVP de e‑commerce multi‑modal en Venezuela: venta al detal y al mayor, pre‑order con abonos, referidos y dropshipping interno. Pagos descentralizados por vendedor (Stripe, PayPal, Pago Móvil, Zelle, Binance Pay/USDT).

### 1) Alcance del MVP
- Flutter app (APK Android)
- Backend Laravel 10 + MySQL 8 (VPS)
- Login con Google OAuth2
- Catálogo, carrito y checkout
- Pagos API (Stripe/PayPal/Binance) y no‑API (Pago Móvil/Zelle)
- Panel admin mínimo (backend o módulo móvil)

Fuera de alcance (post‑MVP): web Angular, IA recomendaciones, multi‑país, fidelización avanzada, múltiples integraciones logísticas.

### 1.1) Modelo de negocio (reglas en UI)
- Detal: precio unitario; requiere stock disponible.
- Mayor: validar cantidad mínima (`min_mayor`); mostrar precio unitario al mayor; bloquear checkout si no cumple.
- Pre‑order: mostrar ETA; soportar abonos y saldo; impedir marcar entregado hasta 100% del pago.
- Referidos: generar/usar link de referido por producto; mostrar comisión estimada cuando aplica.
- Dropshipping interno: referenciar producto origen; mostrar stock efectivo del origen; validar stock al agregar al carrito y al checkout.

### 2) Estructura del proyecto
- `lib/models/`
- `lib/screens/`
- `lib/widgets/`
- `lib/services/` (API centralizada)
- `lib/providers/` (Provider estado)
- `lib/utils/`

### 3) Instalación y ejecución
Requisitos: Flutter 3.x, Dart 3.x

1. Instalar dependencias: `flutter pub get`
2. Configurar variables en `lib/services/config.dart` o `.env` móvil si aplica
   - `API_BASE_URL` (por ejemplo, http://10.0.2.2:8000/api)
   - `OAUTH_GOOGLE_CLIENT_ID` (si aplica en móvil)
   - `FIREBASE_xxx` (si se usan notificaciones)
3. Ejecutar: `flutter run -d android`

### 4) Arquitectura y estándares (Flutter)
- MVVM + Provider
- Validaciones en UI; servicios HTTP en `lib/services` (timeouts y manejo de errores)
- Internacionalización simple (post‑MVP)
- Lint: respetar `analysis_options.yaml`

### 5) Endpoints backend consumidos (mínimos)
- POST `/auth/google`
- GET `/me`
- PUT `/me/rol`
- CRUD `/productos` y `GET /productos?filtros...`
- POST `/carrito`, DELETE `/carrito/{item}`
- POST `/checkout`
- POST `/pagos/{proveedor}` y POST `/webhooks/{proveedor}`
- POST `/pagos/comprobante`
- GET `/pedidos`, GET `/vendedor/pedidos`, PUT `/vendedor/pedidos/{id}/estado`
- GET `/notificaciones`

Ejemplo de consumo (Dart, simplificado):
```dart
final client = HttpClient(baseUrl: env.API_BASE_URL);
final res = await client.post('/checkout', body: orderPayload);
if (res.ok) {
  // navegar a detalle de pedido
} else {
  // mostrar error
}
```

### 6) Flujos principales
- Comprador: login → catálogo → carrito → checkout → pago → seguimiento → notificaciones
- Vendedor: upgrade a vendedor → publicar → inventario → pedidos → pre‑order/abonos → referidos → dropshipping
- Admin: usuarios/productos/pedidos/disputas/comisiones/reportes

### 7) Requisitos funcionales (resumen + criterios)
- Registro/Auth (Google OAuth2)
  - [ ] Login operativo
  - [ ] Onboarding con selección de rol
  - [ ] Cambio a vendedor con RIF/banco/dirección
  - [ ] Rol admin no en onboarding
- Publicación de productos (CRUD con modalidades)
  - [ ] Selector dinámico por modalidad
  - [ ] Pre‑order con abonos y saldo
  - [ ] Dropshipping vincula a producto origen y valida stock
  - [ ] Referidos genera link único por producto
- Carrito y Checkout
  - [ ] Valida cantidad mínima (mayor)
  - [ ] Valida esquema pre‑order
  - [ ] Total correcto
- Pagos (descentralizado)
  - [ ] Mostrar solo métodos habilitados por vendedor
  - [ ] Webhooks marcan pedido pagado
  - [ ] Flujo con comprobante crea evento de validación
- Inventario del vendedor
  - [ ] Descuento de stock al vender
  - [ ] Registro de movimientos visible
  - [ ] Alertas de bajo stock
- Pedidos
  - [ ] Estados auditados
  - [ ] Entrega pre‑order solo con 100% pago
- Notificaciones
  - [ ] Correo e internas por eventos

### 8.1) Manejo de errores (UI/Servicios)
- Estándar de errores API: `{ message, errors?, code }`
- Reintentos básicos en errores de red/transitorios
- Mostrar feedback claro en formularios (errores campo a campo)

### 8) Requisitos no funcionales (MVP)
- Rendimiento: API ≤2s (pequeños), ≤4s (grandes); paginación y caché básico
- Seguridad: HTTPS, OAuth2 Google, roles/permisos, sanitización, CSRF/XSS/SQLi, secretos en `.env`
- Escalabilidad: modular; preparado para colas/cache (opcional)
- Disponibilidad: backup diario MySQL; monitoreo básico

### 9) KPIs
- APK + backend en producción en 1 mes
- Tiempos API: ≤2s/≤4s
- 99.9% uptime; 98% pagos operativos

### 10) Roadmap (4 semanas)
- S1: Infra + Auth
- S2: Comprador (catálogo, carrito, checkout)
- S3: Vendedor (publicación, inventario, pedidos, pre‑order)
- S4: Admin + QA + Deploy + APK

### 11) Desarrollo y contribución
- Commits convencionales: `tipo(scope): resumen` (feat, fix, refactor, docs, chore)
- PRs pequeñas, con checklist y pruebas locales
- Seguir `analysis_options.yaml` y convenciones descritas en `.cursorrules`

### 12) Testing
- Unit, widget e integración en `test/`
- Ejecutar: `flutter test`
  - Integración: flujos de login, carrito, checkout
  - Widget: validaciones de formularios y estados vacíos

### 13) Riesgos y mitigación
- Comprobantes falsos (Pago Móvil/Zelle) → validación manual + evidencia; umbrales/suspensiones
- Retrasos pre‑order → comunicar ETA, recordatorios, opción de reembolso
- Cumplimiento legal → Términos/Políticas; KYC básico a vendedores
- Rendimiento → paginación, índices y caché básico

### 14) Integración con Backend
- `API_BASE_URL`: debe apuntar a `/api` del backend (p. ej., `http://10.0.2.2:8000/api`).
- Autenticación: enviar `Authorization: Bearer <token>` (Sanctum token).
- CORS: el backend debe permitir el origen de la app; usar `FRONTEND_URL` en `.env` backend.
- Paginación: usar `?page=N&per_page=M`; backend responde `{ data, meta: { current_page, per_page, total } }`.
- Errores: el backend responde `{ message, errors?, code }`; mapear `errors` a campos en formularios.
- Fechas: ISO 8601 UTC; convertir a zona local en UI.
- Moneda: valores en decimales; mostrar en VES/USDT según contexto.


