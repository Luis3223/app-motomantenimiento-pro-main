# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Dueños de moto que mantienen su vehículo con el proveedor **Casa Racing**. Quieren saber cuándo toca el siguiente servicio (sobre todo el cambio de aceite), llevar un historial confiable de lo hecho y contactar al taller o la tienda sin salir de la app.

Audiencia secundaria confirmada por el producto: personal **admin** de Casa Racing, que ve usuarios del dispositivo y puede enviar avisos.

## Product Purpose

**Moto Mantenimiento Pro** es la app de seguimiento de mantenimiento de motos del proveedor real **Casa Racing**. Permite registrar la moto y los servicios, ver el estado del ciclo de aceite, consultar el historial y el perfil, y abrir canales reales del negocio (WhatsApp y tienda).

Éxito: el motero no se pasa del servicio, tiene un registro claro de lo hecho en su moto, y puede pasar a agendar o comprar con Casa Racing desde la app.

## Positioning

No es un recordatorio genérico ni un cuaderno digital suelto: es la app de mantenimiento ligada al proveedor **Casa Racing**. El nombre del producto es **Moto Mantenimiento Pro**; Casa Racing es el partner/proveedor real, no un placeholder de marca.

## Operating Context

- Uso principal en el teléfono Android del motero (garage / vía / casa).
- Flujos centrales: login o registro → Mi Garage (estado del aceite y resumen) → Historial (servicios + alta) → Mi Perfil; contacto por WhatsApp y enlace a la tienda virtual.
- Admin: panel bajo Historial para ver usuarios y disparar alertas.
- Hoy los datos viven en SQLite local en el dispositivo; no hay backend real de sincronización (mensajes de “Firebase” en UI son simulados y no deben tratarse como sincronización verdadera).

## Capabilities and Constraints

Confirmado en producto/código:

- Auth local (usuario / admin), registro de moto (modelo, placa, año, VIN).
- Dashboard de garage con ciclo de aceite orientado a **30 días**, historial de servicios, alta de registro, perfil editable.
- Roles: usuario y admin.
- Enlaces operativos presentes en código: WhatsApp `+57 322 506 2876`, tienda `https://tiendavirtualcasaracing.lovable.app/`.
- Stack existente: Flutter + Material 3, `provider`, `go_router`, `sqflite`, `url_launcher`.

Abiertos / no inventar:

- Si el ciclo de 30 días es la regla de negocio definitiva de Casa Racing o una aproximación al manual del fabricante.
- Si el número de WhatsApp y la URL de tienda son los canales de producción finales.
- Backend real, push y sync offline-first (previsto en backlog, no desplegado).
- Accesibilidad y requisitos de inclusión específicos del negocio: no establecidos.

## Brand Commitments

- Nombre del producto: **Moto Mantenimiento Pro** (también aparece como MotoMantenimiento Pro en código/paquete).
- Proveedor real: **Casa Racing** (copy y flujos: “Casa Racing Store Partner”, “Casa Racing MotoPro”, “Agendar en Casa Racing”, tips de servicio).
- No fabricar testimonios, certificaciones ni claims de sincronización en la nube mientras no existan.

## Evidence on Hand

- Código de pantallas y tema en `lib/` (login, garage, historial, perfil, admin).
- README con cuentas demo y stack.
- Backlog en `docs/Backlog.md` (bugs, honestidad de copy Firebase, épica de backend).
- No hay logos ni assets de marca en el repo (solo iconos Material). No inventar materiales de Casa Racing.

## Product Principles

1. Honestidad operativa: no afirmar sync, push o backend que no existan.
2. El vínculo con Casa Racing es el valor: servicio, contacto y tienda del proveedor real.
3. El ciclo de mantenimiento (aceite primero) debe ser escaneable en segundos.
4. Datos de la moto y del historial son del usuario; no perderlos por migraciones destructivas ni demos en release.
5. Admin es privilegio real, no solo un botón oculto en UI.
