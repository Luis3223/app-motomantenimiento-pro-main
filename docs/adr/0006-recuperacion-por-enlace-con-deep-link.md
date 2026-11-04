---
status: accepted
---

# Recuperación de contraseña por enlace con deep link

Reemplaza la parte de recuperación del ADR 0005. El código de un solo uso necesitaba editar la plantilla «Reset password» para incluir `{{ .Token }}`, y Supabase no permite editar plantillas en el plan Free sin un SMTP propio. La recuperación usa ahora el enlace de la plantilla por defecto: `resetPasswordForEmail` con `redirectTo` = `com.aistudio.motomantenimiento.pkmvqw://reset-password` (`passwordResetRedirect` en `lib/config.dart`). Android abre la app por un `intent-filter`, `supabase_flutter` canjea el código y emite `passwordRecovery`; `MotoApp` lleva a `/reset-password`, donde el usuario fija la contraseña con `updateUser`. Después se cierra esa sesión y el usuario entra por el login normal. Un enlace vencido o ya usado lleva de vuelta a `/forgot-password` con un aviso.

La sesión que abre el enlace solo sirve para cambiar la contraseña: `SupabaseAuthRepository.currentSession` ignora los tokens cuyo claim `amr` tiene el método `recovery`, así que el arranque no la toma como inicio de sesión.

## Considered Options

- **Configurar SMTP propio y mantener el código**: hace falta igualmente para enviar correos a clientes reales (el correo integrado solo llega a miembros del equipo y con un límite bajo por hora), pero depende de credenciales de un proveedor de correo que aún no existe. Queda pendiente para la publicación (tarea 25).
- **Esperar al SMTP**: dejaba la tarea 24 sin funcionar. Descartada.

## Consequences

- La Redirect URL está registrada en Supabase (Authentication → URL Configuration).
- El enlace usa PKCE: hay que abrirlo en el mismo teléfono donde se pidió.
- Abrir el enlace con una sesión ya iniciada en la app no está soportado: el router manda al garage.
- Con el correo integrado de Supabase, el enlace solo llega a direcciones del equipo del proyecto. Para clientes reales hace falta SMTP propio (tarea 25).
