---
status: accepted
---

# Acceso con Google nativo y recuperación de contraseña por código

> La parte de recuperación por código quedó reemplazada por `docs/adr/0006-recuperacion-por-enlace-con-deep-link.md`.

Las tareas 23 y 24 se apoyan en Supabase Auth (ADR 0002). El acceso con Google usa el selector nativo de Android (`google_sign_in`) y entrega el ID token a `signInWithIdToken`; Supabase valida el token contra el cliente OAuth «Web» y enlaza la identidad con la cuenta que ya tenga el mismo correo verificado. La app reutiliza la copia local por correo normalizado (`adoptRemoteUser`), así que no se duplican cuentas. La recuperación de contraseña envía un código de un solo uso: el usuario lo escribe en la app junto con la contraseña nueva (`verifyOTP` + `updateUser`) y después entra por el login normal. El mensaje de envío es neutro («si el correo tiene una cuenta…»): no existe el estado «cuenta no encontrada».

## Considered Options

- **OAuth en el navegador con deep link** (`signInWithOAuth`): menos configuración en Google, pero saca al usuario a Chrome y obliga a registrar un esquema propio. Descartada.
- **Enlace de recuperación con deep link** (evento `passwordRecovery`): exige esquema propio en `AndroidManifest.xml` y URL de redirección permitida. Descartada por la misma razón; el código no necesita rutas con parámetros.
- **RPC que dice si un correo existe**: cumpliría el texto literal de la tarea 24, pero permite a cualquiera averiguar qué correos son clientes de Casa Racing. Descartada.

## Consequences

- Configuración externa necesaria: cliente OAuth «Web» y cliente «Android» (paquete `com.aistudio.motomantenimiento.pkmvqw` + SHA-1 de la firma) en Google Cloud; proveedor Google activado en Supabase con el ID del cliente Web; `googleWebClientId` en `lib/config.dart`; plantilla «Reset password» de Supabase con `{{ .Token }}`.
- Al cambiar la firma de release (tarea 25) hay que registrar su SHA-1 en el cliente Android.
- El enlace automático de identidades depende de que el correo de la cuenta existente esté confirmado; hoy la confirmación está desactivada y todas lo están. Si se activa, las cuentas sin confirmar no se enlazarán.
