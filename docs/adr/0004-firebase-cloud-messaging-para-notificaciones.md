---
status: accepted
---

# Firebase Cloud Messaging para notificaciones Android

Firebase se usa en MotoMantenimiento Pro únicamente como proveedor de entrega de notificaciones push mediante **Firebase Cloud Messaging (FCM)**. No se usa Firebase Auth, Firestore, Realtime Database ni Storage: la autenticación, los perfiles, el historial y la lógica de servidor pertenecen a Supabase, tal como establecen los ADR 0002 y 0003.

## Configuración Android

El proyecto Firebase es `motomantenimiento-pro` y está vinculado al `applicationId` Android mediante `android/app/google-services.json`. El plugin `com.google.gms.google-services` se aplica desde [android/app/build.gradle](../../android/app/build.gradle). Las dependencias Flutter son `firebase_core` y `firebase_messaging`.

Android declara el permiso `POST_NOTIFICATIONS` y el canal `maintenance_alerts`. El permiso debe ser concedido por el usuario para que Android pueda mostrar avisos. La app no contiene credenciales de una cuenta de servicio: las credenciales de servidor para FCM viven en Supabase como el secreto `FCM_SERVICE_ACCOUNT`.

## Flujo de registro y envío

1. Al arrancar, `main()` inicializa Supabase y crea `PushCoordinator` con `FirebaseDevicePush` y `SupabaseRemoteNotifications`.
2. `FirebaseDevicePush.start()` inicializa Firebase, registra el manejador de mensajes en segundo plano, solicita permiso, obtiene el mensaje que abrió la app y se suscribe a mensajes en primer plano, aperturas y renovación del token.
3. `PushCoordinator` obtiene el token de registro FCM con `getToken()`. Cuando hay una sesión de Supabase, guarda el token y la próxima fecha del aceite en `profiles` mediante un `upsert`. También repite este registro cuando FCM notifica una renovación del token.
4. Un administrador inserta un aviso en `notifications` desde Supabase. Los recordatorios del aceite se generan con el cron y la función `push` de Supabase.
5. La función de servidor lee los perfiles con token y llama a la API HTTP v1 de FCM usando `FCM_SERVICE_ACCOUNT`. El mensaje contiene el título, el cuerpo y una ruta de navegación permitida (`/garage` o `/history`); no contiene VIN, kilometraje ni otros datos de la moto.

## Recepción y navegación

- **App en primer plano:** `onMessage` convierte el `RemoteMessage` en `PushMessage` y `MotoApp` lo presenta como una notificación interna mediante `AppController`.
- **App en segundo plano:** Android/FCM muestra el aviso. Al tocarlo, `onMessageOpenedApp` entrega la ruta y el router navega al historial o al garaje cuando existe una sesión.
- **App terminada:** `getInitialMessage()` conserva el mensaje que abrió la aplicación hasta que `MotoApp` conecta el callback de navegación; después se aplica la misma validación de ruta.
- **Payload inválido:** `pushMessageFrom` descarta mensajes cuya ruta no sea `/garage` o `/history`, evitando navegación arbitraria.

El manejador `firebaseMessagingBackgroundHandler` queda registrado para que FCM pueda procesar mensajes durante la ejecución en segundo plano, pero no realiza trabajo adicional. Por tanto, el contenido visible de un aviso con la app cerrada depende de la notificación entregada por FCM y de Android.

## Consecuencias y límites

- Firebase es un canal de transporte Android; no es la fuente de verdad de usuarios, servicios ni sesiones.
- La entrega depende del permiso de notificaciones, de que exista un token vigente y de la configuración de FCM/Supabase.
- Cerrar sesión elimina la sesión remota de Supabase; el token y la fecha del aceite se vuelven a asociar cuando se registra una nueva sesión.
- La renovación de tokens se contempla, pero la entrega con la app completamente cerrada todavía debe validarse en un dispositivo físico con un token registrado.
- Las notificaciones locales no forman parte de esta integración; los avisos descritos aquí son push y se originan en Supabase.

