---
status: accepted
---

# Supabase como backend

La app guarda usuarios y servicios solo en SQLite del dispositivo. La épica de backend (tarea 17 del backlog) dejaba abierto Firebase Auth + Firestore/RTDB, Supabase u otro. El backend será **Supabase**: Auth sustituye la tabla local `users` y cubre el acceso con Google y el restablecimiento de contraseña; Postgres con RLS es la fuente de verdad de servicios, tokens y avisos; las Edge Functions concentran la lógica de servidor. SQLite sigue como caché para la sincronización offline. Las notificaciones push de Android salen por Firebase Cloud Messaging: la app guarda el token en Postgres y una Edge Function llama a FCM. El payload lleva título y un identificador de navegación, sin kilometraje, VIN ni otros datos sensibles.

## Considered Options

- **Firebase Auth + Firestore/RTDB**: alternativa nombrada en el backlog y el texto que la UI llegó a simular. Se descarta como almacén y como autenticación. FCM se conserva solo como canal de entrega en Android.
- **Solo notificaciones locales**: cubre el recordatorio de aceite en el propio teléfono (tarea 18). No cubre los avisos del administrador a otros dispositivos ni la sincronización entre teléfonos.

## Consequences

- Hace falta un proyecto de Firebase limitado a las credenciales de mensajería.
- Las tareas 16, 17, 25 y 26 se implementan sobre este stack. No hay sincronización en la nube hasta que esa épica esté hecha.
- El plan de implementación queda en `docs/Backlog.md` (tarea 17).
