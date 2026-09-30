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
> **Hecho (2026-09-29):** `_createTables` compartido y `_migrate` incremental. La reconstrucción solo se mantiene para v1 → v2 (esquema prototipo); las versiones futuras deben usar `ALTER TABLE`. Sin test automático (requiere `sqflite_common_ffi`, ver tarea 18).

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
> **Hecho (2026-09-29):** suscripción antes de la consulta inicial; si llega antes un evento en vivo, se descarta el resultado inicial. Sin test automático (requiere `sqflite_common_ffi`, ver tarea 18).

- **Problema:** en `repository.dart` el listener se suscribe al controller después de un `await`, así que se puede perder un evento emitido durante la carga inicial.
- **Tarea:** suscribirse antes de hacer la consulta inicial, o usar un `BehaviorSubject` / último valor cacheado.

---

## P2 — Datos y veracidad del producto

### 9. Quitar los mensajes falsos de Firebase · S
- **Problema:** la app afirma "sincronizado de forma segura con Firebase RTDB", "sincronizado en tiempo real" y "enviada a los dispositivos activos", pero no existe ningún backend.
- **Tarea:** cambiar los textos por mensajes honestos ("Guardado en el dispositivo") y ocultar el indicador de estado de Firebase del Dashboard mientras la sincronización no sea real.
- **Archivos:** `repository.dart`, `app_controller.dart`, `dashboard_screen.dart`, `admin_screen.dart`.

### 10. Eliminar datos inventados en la UI · M
- `detail_screen.dart`: "Llantas: Óptimo" está escrito a mano; calcularlo a partir del último servicio de llantas o quitarlo.
- `handleRegister`: el VIN se genera al azar con el prefijo `YMA` y el año es siempre `2024`. Añadir campos opcionales de año y VIN al registro y al perfil.
- `_updateDashboardCalculations`: el `catch` muestra valores ficticios ("Faltan 18 días"); mostrar "Fecha inválida" en su lugar.
- El "odómetro" es el kilometraje más alto de los servicios; considerar un campo `currentMileage` en el usuario.

### 11. Datos semilla coherentes · S
- En `tryPrepopulate` hay un servicio más reciente con menos km que uno anterior (frenos hace 45 días con 10 500 km, llantas hace 60 días con 11 200 km). Ajustar los datos para que el kilometraje crezca con la fecha.

### 12. Validar el kilometraje al registrar un servicio · S
- Rechazar valores negativos y avisar si el km es menor que el de un servicio anterior con fecha más antigua.

### 24. Actualizar el logo de la app · M
- **Problema:** la app usa el icono por defecto de Flutter y no tiene splash propio.
- **Tarea:** actualizar la imagen del logo en el icono del launcher (incluido el icono adaptativo de Android) y en el splash, idealmente generándolos con `flutter_launcher_icons` y `flutter_native_splash` para no editarlos a mano en `android/`.
- **Bloqueo:** requiere el logo oficial. Hoy el repo no tiene assets de marca y `PRODUCT.md` prohíbe inventar material de Casa Racing.
- **Criterio de aceptación:** el icono del launcher y el splash muestran el logo oficial en Android.

---

## P3 — Seguridad (antes de producción)

### 13. No guardar contraseñas en texto plano · M
- Guardar un hash con sal (p. ej. `crypto` con PBKDF2, o `bcrypt`) en lugar de la contraseña.
- Incluir una migración que convierta las contraseñas existentes.

### 14. Retirar las cuentas demo en release · S
- Ejecutar `tryPrepopulate` solo en `kDebugMode`, o detrás de un flag de compilación. Las credenciales `admin` / `admin` no deben llegar a producción.

### 15. Persistir la sesión · M
- Hoy se pierde la sesión al cerrar la app. Guardar el id del usuario (p. ej. con `shared_preferences` o `flutter_secure_storage`) y restaurarla en `init()`.

---

## P4 — Backend real (épica)

### 16. Sincronización real · L
- Definir el backend (Firebase Auth + Firestore/RTDB, Supabase, u otro).
- Autenticación real que reemplace la tabla local `users`.
- Sincronización offline-first: SQLite como caché local, con cola de cambios pendientes.
- Push reales (FCM) para recordatorios de aceite y avisos del admin.
- Panel de admin con datos de todos los clientes, no solo los del dispositivo.

### 17. Recordatorios locales programados · M
- Mientras no haya backend, usar `flutter_local_notifications` para avisar 5 días antes y el día del vencimiento del cambio de aceite, aunque la app esté cerrada.

---

## P5 — Calidad y plataforma

### 18. Tests · M
- Extraer el cálculo del ciclo de aceite a una función pura que reciba `now` como parámetro y cubrirla con tests (sin servicios, sin aceite, vencido, aviso de 5 días, al día).
- Tests del repositorio con `sqflite_common_ffi` (login, registro duplicado, insertar y borrar).
- Test de redirección del router (no logueado, no admin en ruta de admin).

### 19. Soporte de plataformas · S
- `sqflite` solo funciona en Android e iOS. Decidir entre:
  - eliminar las carpetas `windows/`, `linux/`, `macos/` y `web/`, o
  - añadir `sqflite_common_ffi` para escritorio (y `sqflite_common_ffi_web` para web).

### 20. Configuración centralizada · S
- Mover `whatsappNumber` y `storeUrl` de `app_router.dart` a un archivo `lib/config.dart`.
- Mostrar un `SnackBar` si `canLaunchUrl` falla, en lugar de no hacer nada.

### 21. Limpieza menor · S
- Unificar los timers de sincronización duplicados entre `Repository.triggerFirebaseSync` y `AppController._syncFromRepo`, o eliminarlos junto con la tarea 9.
- Cambiar `DateTime.now()` repetido tres veces en `_updateDashboardCalculations` por una sola variable.
- Usar un `enum` para `type` y `category` en lugar de strings, en vez de detectar el aceite con `contains('aceite')`.

### 22. Migración incremental a MVVM · L
> Decisión en `docs/adr/0001-mvvm-incremental.md`. Regla: cada cambio que toque una feature la migra; no se añaden responsabilidades nuevas a `AppController`.

- **Problema:** `AppController` (≈380 líneas) y `Repository` (≈350) concentran varias responsabilidades (SRP) y todas las pantallas dependen de ellos.
- **Tareas, en orden sugerido:**
  1. Capa de datos: separar `AppDatabase` como *service* y dividir `Repository` en `UserRepository`, `ServiceRecordRepository` y `NotificationRepository`, inyectados por constructor.
  2. Extraer el cálculo del ciclo de aceite a una función pura/Use Case con `now` inyectable (coincide con la tarea 18).
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
