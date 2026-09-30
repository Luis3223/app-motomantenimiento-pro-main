# Backlog — MotoMantenimiento Pro

Tareas pendientes detectadas en el análisis del código (2026-09-29), ordenadas por prioridad.

Leyenda de esfuerzo: **S** (< 1 h) · **M** (medio día) · **L** (1+ días)

---

## P0 — Crítico

### 1. ✅ Proteger la ruta de administración · S
> **Hecho (2026-09-29):** guard en el `redirect` + tests en `test/router_test.dart`.

- **Problema:** el `redirect` de `lib/router/app_router.dart` solo verifica que haya sesión. Cualquier usuario logueado puede entrar a `/history/admin` y ver todos los usuarios o enviar alertas. El botón solo se oculta en la UI (`history_screen.dart`).
- **Tarea:** en el `redirect`, si la ruta empieza por `/history/admin` y `controller.currentUser?.isAdmin != true`, redirigir a `/history`.
- **Criterio de aceptación:** un usuario no admin que navega a `/history/admin` termina en `/history`.

### 2. ✅ Eliminar el `onUpgrade` destructivo · S
> **Hecho (2026-09-29):** `_createTables` compartido y `_migrate` incremental. La reconstrucción solo se mantiene para v1 → v2 (esquema prototipo); las versiones futuras deben usar `ALTER TABLE`. Sin test automático (requiere `sqflite_common_ffi`, ver tarea 19).

- **Problema:** `lib/data/database/app_database.dart` hace `DROP TABLE` de `users` y `services` en cualquier cambio de versión. Subir `version` borraría todos los datos reales.
- **Tarea:** extraer la creación de tablas a una función compartida y sustituir `onUpgrade` por migraciones incrementales (`if (oldVersion < 3) { ALTER TABLE ... }`).
- **Criterio de aceptación:** actualizar la app de una versión de esquema a otra conserva usuarios y servicios.

---

## P1 — Bugs funcionales

### 3. ✅ Detalle del servicio seleccionado · M
> **Hecho (2026-09-29):** `ServiceDetailScreen` en `/history/service`, con opción de eliminar.

- **Problema:** al tocar un servicio en el historial se llama a `selectService(s)` y se navega a `/garage/detail`, pero `DetailScreen` nunca lee `selectedService`: muestra los datos de la moto, no los del servicio.
- **Tarea:** crear `ServiceDetailScreen` en `/history/service` que muestre tipo, fecha, km, categoría y notas del servicio seleccionado. Cambiar la navegación del historial a esa ruta.
- **Criterio de aceptación:** tocar un servicio muestra su información; volver regresa al historial.

### 4. ✅ Alertas y notificaciones duplicadas · S
> **Hecho (2026-09-29):** `Set` de títulos ya mostrados; se reinicia al hacer login, al cerrar sesión o cuando el aceite vuelve a estar al día.

- **Problema:** `_triggerSimulationAlert` (`app_controller.dart`) solo deduplica mientras la alerta está visible. Tras cerrarla, cada emisión del stream la vuelve a crear y agrega otra entrada a `notifications`, que crece sin límite.
- **Tarea:** llevar registro de las alertas ya mostradas en la sesión (p. ej. un `Set<String>` de títulos) y no volver a disparar la misma hasta el siguiente login o hasta que cambie el estado del aceite.
- **Criterio de aceptación:** registrar varios servicios seguidos no genera alertas repetidas.

### 5. ✅ Mostrar o eliminar el centro de notificaciones · M
> **Hecho (2026-09-29):** opción (a), campana en el Dashboard que abre un bottom sheet. Pendiente: marcar como leídas / contador (`isRead` sigue sin usarse).

- **Problema:** `AppController.notifications` se llena pero ninguna pantalla lo muestra.
- **Tarea:** decidir entre (a) añadir una pantalla o bottom sheet de notificaciones, con acceso desde un ícono de campana en el Dashboard, o (b) eliminar el estado que no se usa.

### 6. ✅ Confirmar antes de borrar servicios · S
> **Hecho (2026-09-29):** `AlertDialog` compartido en `widgets/confirm_delete_service.dart`.

- **Problema:** el ícono de borrar en `history_screen.dart` elimina el registro al primer toque.
- **Tarea:** mostrar un `AlertDialog` de confirmación, o permitir deshacer con un `SnackBar` y la acción "Deshacer".

### 7. ✅ Normalizar el correo electrónico · S
> **Hecho (2026-09-29):** normalización en el controller, consulta con `LOWER(email)` y validación de formato en el registro.

- **Problema:** el login y el registro distinguen mayúsculas y minúsculas; `Luis@gmail.com` y `luis@gmail.com` serían cuentas distintas.
- **Tarea:** aplicar `trim().toLowerCase()` al correo en `handleLogin`, `handleRegister` y `getUserByEmail`. Validar el formato del correo en el registro.

### 8. ✅ Pérdida de eventos en `watchServicesForUser` · S
> **Hecho (2026-09-29):** suscripción antes de la consulta inicial; si llega antes un evento en vivo, se descarta el resultado inicial. Sin test automático (requiere `sqflite_common_ffi`, ver tarea 19).

- **Problema:** en `repository.dart` el listener se suscribe al controller después de un `await`, así que se puede perder un evento emitido durante la carga inicial.
- **Tarea:** suscribirse antes de hacer la consulta inicial, o usar un `BehaviorSubject` / último valor cacheado.

---

## P2 — Datos y veracidad del producto

### 9. ✅ Quitar los mensajes falsos de Firebase · S
> **Hecho (2026-09-30):** eliminados `FirebaseSyncStatus`, `firebaseStatus`, `triggerFirebaseSync`, `forceSync` y los timers de sincronización; textos cambiados a "guardado en este dispositivo"; quitado el indicador del Dashboard.
- **Problema:** la app afirma "sincronizado de forma segura con Firebase RTDB", "sincronizado en tiempo real" y "enviada a los dispositivos activos", pero no existe ningún backend.
- **Tarea:** cambiar los textos por mensajes honestos ("Guardado en el dispositivo") y ocultar el indicador de estado de Firebase del Dashboard mientras la sincronización no sea real.
- **Archivos:** `repository.dart`, `app_controller.dart`, `dashboard_screen.dart`, `admin_screen.dart`.

### 10. ✅ Eliminar datos inventados en la UI · M
> **Hecho (2026-09-30):** sin VIN ni año inventados (campos opcionales en el registro; el perfil los muestra, editarlos queda en la tarea 28); fecha ilegible → "Fecha inválida"; `DetailScreen` mostraba textos vacíos y ahora usa datos reales (el "Llantas: Óptimo" ya no existía). Pendiente: campo `currentMileage` en el usuario.
- `detail_screen.dart`: "Llantas: Óptimo" está escrito a mano; calcularlo a partir del último servicio de llantas o quitarlo.
- `handleRegister`: el VIN se genera al azar con el prefijo `YMA` y el año es siempre `2024`. Añadir campos opcionales de año y VIN al registro y al perfil.
- `_updateDashboardCalculations`: el `catch` muestra valores ficticios ("Faltan 18 días"); mostrar "Fecha inválida" en su lugar.
- El "odómetro" es el kilometraje más alto de los servicios; considerar un campo `currentMileage` en el usuario.

### 11. ✅ Datos semilla coherentes · S
> **Hecho (2026-09-30):** llantas (hace 60 días) pasan a 10 000 km. Sin test automático (requiere `sqflite_common_ffi`, tarea 19); solo afecta a instalaciones nuevas.
- En `tryPrepopulate` hay un servicio más reciente con menos km que uno anterior (frenos hace 45 días con 10 500 km, llantas hace 60 días con 11 200 km). Ajustar los datos para que el kilometraje crezca con la fecha.

### 12. ✅ Validar el kilometraje al registrar un servicio · S
> **Hecho (2026-09-30):** negativos rechazados; si el km es menor que el de un servicio de fecha anterior se guarda y se avisa. La pantalla de alta ya no navega si el guardado falla.
- Rechazar valores negativos y avisar si el km es menor que el de un servicio anterior con fecha más antigua.

---

## P3 — Seguridad (antes de producción)

### 13. ✅ No guardar contraseñas en texto plano · M
> **Hecho (2026-09-30):** `PasswordHasher` (PBKDF2-HMAC-SHA256, sal aleatoria de 16 bytes, 60 000 iteraciones, formato `pbkdf2$iter$sal$hash`, con prueba contra el vector RFC 7914). Migración v3 que convierte las contraseñas en texto plano. La migración no tiene test automático (requiere `sqflite_common_ffi`, tarea 18). 60 000 es menos de lo que recomienda OWASP (600 000) por el coste del Dart puro en móvil; súbelo cuando haya un backend o un paquete nativo.
- Guardar un hash con sal (p. ej. `crypto` con PBKDF2, o `bcrypt`) en lugar de la contraseña.
- Incluir una migración que convierta las contraseñas existentes.

### 14. ✅ Retirar las cuentas demo en release · S
> **Hecho (2026-09-30):** `Repository(seedDemoData: kDebugMode)`; en release solo se siembran los tipos de servicio. Sin test automático (tarea 18).
- Ejecutar `tryPrepopulate` solo en `kDebugMode`, o detrás de un flag de compilación. Las credenciales `admin` / `admin` no deben llegar a producción.

### 15. ✅ Persistir la sesión · M
> **Hecho (2026-09-30):** tabla `session` en SQLite (esquema v3) en lugar de `shared_preferences`, sin dependencia nueva; `Repository.restoreSession()` se llama en `AppController.init()`. Se borra al cerrar sesión o si la cuenta ya no existe.
- Hoy se pierde la sesión al cerrar la app. Guardar solo el id o correo normalizado del usuario (p. ej. con `shared_preferences` o `flutter_secure_storage`), nunca la contraseña.
- Restaurar el usuario desde SQLite durante `init()` y mantenerlo autenticado al volver a abrir la aplicación.
- Borrar el identificador persistido únicamente cuando el usuario cierre sesión explícitamente.
- Eliminar la sesión guardada si el usuario ya no existe o sus datos no son válidos.

### 16. Notificaciones push · L
- Integrar Firebase Cloud Messaging (FCM) o el proveedor que se defina para enviar recordatorios de mantenimiento y avisos del administrador aunque la app esté cerrada.
- Gestionar permisos, registro y renovación de tokens, recepción en primer plano y navegación al contenido relacionado al tocar una notificación.
- Requiere backend real, autenticación de dispositivos y control para no enviar datos sensibles en el payload.

---

## P4 — Backend real (épica)

### 17. Sincronización real · L
- Definir el backend (Firebase Auth + Firestore/RTDB, Supabase, u otro).
- Autenticación real que reemplace la tabla local `users`.
- Sincronización offline-first: SQLite como caché local, con cola de cambios pendientes.
- Panel de admin con datos de todos los clientes, no solo los del dispositivo.

### 18. Recordatorios locales programados · M
- Mientras no haya backend, usar `flutter_local_notifications` para avisar 5 días antes y el día del vencimiento del cambio de aceite, aunque la app esté cerrada.

---

## P5 — Calidad y plataforma

### 19. Tests · M

### 20. Soporte de plataformas · S
## P6 — Evolución funcional y publicación

### 24. API de datos técnicos y configuración de mantenimiento · L
- Crear una API para gestionar datos manuales de la moto, fichas técnicas, configuraciones, alertas y la periodicidad recomendada de cambio de aceite.
- Definir el contrato de datos, autenticación y fuente de verdad antes de conectarla con la app.
- Mantener la regla de 30 días configurable y no presentarla como definitiva hasta confirmarla con Casa Racing o el fabricante.

### 25. Registro y acceso con Google · M
- Añadir registro e inicio de sesión con Google.
- Vincular la cuenta social con el usuario local existente sin duplicar cuentas por correo normalizado.
- Requiere autenticación real y backend; no debe implementarse como una simulación local.

### 26. Recuperación y reenvío de contraseña · M
- Permitir solicitar el reenvío o restablecimiento de contraseña desde la pantalla de login.
- Mostrar estados claros para correo enviado, cuenta no encontrada y solicitud inválida.
- Requiere autenticación real y un servicio de correo; no exponer contraseñas almacenadas.

### 27. Preparación para publicación en Google Play · L
- Configurar identificador, firma, versión, icono, permisos, política de privacidad y ficha de la aplicación.
- Generar y validar un `app bundle` de release en un entorno limpio.
- Retirar cuentas demo, credenciales de prueba y mensajes de sincronización simulada antes de publicar.

### 28. Activar acciones pendientes de la interfaz · M
- Hacer operativos los botones que todavía solo muestran un mensaje o no tienen acción.
- Cubrir como mínimo edición del perfil, exportación de datos, borrado del historial, chat y cualquier acción equivalente que siga pendiente en las pantallas.
- Cada acción debe persistir o ejecutar su operación real, mostrar error recuperable y tener una prueba de regresión del flujo principal.
- Mover `whatsappNumber` y `storeUrl` de `app_router.dart` a un archivo `lib/config.dart`.
- Mostrar un `SnackBar` si `canLaunchUrl` falla, en lugar de no hacer nada.

### 21. Limpieza menor · S
- ✅ (2026-09-30) Timers de sincronización eliminados junto con la tarea 9.
- ✅ (2026-09-30) `DateTime.now()` unificado en `_updateDashboardCalculations`.
- Usar un `enum` para `type` y `category` en lugar de strings, en vez de detectar el aceite con `contains('aceite')`.

### 22. Migración incremental a MVVM · L
> Decisión en `docs/adr/0001-mvvm-incremental.md`. Regla: cada cambio que toque una feature la migra; no se añaden responsabilidades nuevas a `AppController`.

- **Problema:** `AppController` (≈380 líneas) y `Repository` (≈350) concentran varias responsabilidades (SRP) y todas las pantallas dependen de ellos.
- **Tareas, en orden sugerido:**
  1. Capa de datos: separar `AppDatabase` como *service* y dividir `Repository` en `UserRepository`, `ServiceRecordRepository` y `NotificationRepository`, inyectados por constructor.
  2. Extraer el cálculo del ciclo de aceite a una función pura/Use Case con `now` inyectable (coincide con la tarea 19).
  3. Sesión: un `SessionRepository` (o ViewModel de sesión) como única fuente del usuario actual, usado por el `redirect` del router.
  4. Un ViewModel por feature: `auth` (login/registro), `garage`, `history` (lista, alta, detalle), `profile`, `admin`.
  5. Reorganizar carpetas a `lib/ui/features/<feature>/{views,view_models}`, `lib/ui/core/`, `lib/data/{services,repositories,models}`, `lib/domain/`.
  6. Eliminar `AppController` cuando ya no tenga consumidores.
- **Criterio de aceptación:** ninguna pantalla depende de `AppController`; cada ViewModel tiene tests con repositorios falsos.

### 23. Adoptar `very_good_analysis` de forma incremental · M
- **Tarea:**
  1. Añadir `very_good_analysis` a `dev_dependencies` e incluirlo en `analysis_options.yaml` en lugar de `flutter_lints`.
  2. Contar los avisos por regla y desactivar temporalmente en `analysis_options.yaml` las reglas que hoy fallan, con un comentario `# TODO(backlog-23)`.
  3. Reactivar las reglas por lotes pequeños, corrigiendo el código en cada lote (idealmente junto con la migración de la tarea 22).
- **Criterio de aceptación:** no queda ninguna regla desactivada con `TODO(backlog-23)` y `flutter analyze` sigue sin avisos.
