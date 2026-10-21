---
status: accepted
---

# Cola offline en SQLite

La sincronización de la tarea 17 usa una cola en SQLite (`pending_changes`) y el cliente de Supabase que ya está en la app. Postgres sigue siendo la fuente de verdad: al confirmar un envío, el servidor pone `updated_at`. Si esa marca es posterior a la base que tenía el cambio local, gana la fila remota y el cambio se descarta. Un borrado es `deleted_at`, para que no lo pise una edición más vieja. La primera subida, que aún no tiene base, se envía aunque el servidor ya tenga una fila.

## Considered Options

- **PowerSync u otro motor de sincronización**: cubre conflictos y tiempo real, y añade un servicio y un modelo de datos propios. Se descarta: la app ya tiene SQLite y `supabase_flutter`, y el volumen es el historial de una moto.
- **Solo en línea, sin cola**: más simple, y pierde el alta de un servicio cuando no hay red.

## Consequences

- No hay actualización en vivo: se envía al guardar, al entrar y al volver la app a primer plano.
- Un cambio de token o de la fecha de aceite no mueve `profiles.updated_at`, para no ganar un conflicto de perfil.
