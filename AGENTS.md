# AGENTS.md

Reglas del proyecto para cualquier agente de código (Claude Code, Cursor, etc.). Es la **fuente única**: los archivos específicos de cada herramienta (`CLAUDE.md`, `.cursor/`) solo la importan y añaden lo propio de esa herramienta. No dupliques aquí contenido de otros documentos: enlázalo.

## Proyecto

**Moto Mantenimiento Pro**: app Flutter (solo Android) de seguimiento de mantenimiento de motos, ligada al proveedor real **Casa Racing**. Todo el texto de UI, la documentación, los ADR y los commits están en español.

| Documento | Contenido |
|-----------|-----------|
| `PRODUCT.md` | Contexto de producto, usuarios y reglas de marca |
| `DESIGN.md` | Sistema visual (colores, tipografía, tokens) |
| `GLOSSARY.md` | Lenguaje del dominio (se crea con el primer término resuelto) |
| `docs/adr/` | Decisiones de arquitectura (`0001-slug.md`, …) |
| `docs/Backlog.md` | Pendientes priorizados |
| `docs/Changenotes.md` | Registro de cambios de la app y del proyecto (tooling, docs), condensado por versión |

**Rutas:** la carpeta de documentación es `docs/`, **en minúscula**. No crees `Docs/` ni otras variantes: en Windows apuntan a la misma carpeta, pero en git y en CI serían carpetas distintas.

## Definición de terminado

Una tarea está terminada solo si se cumplen todas estas condiciones:

1. `tool/verify.sh` en verde (formato, `flutter analyze` sin avisos y `flutter test`).
2. El comportamiento nuevo o corregido tiene tests: unitarios para ViewModels, repositorios y lógica de dominio; de widget para los flujos críticos de UI; y un test de regresión en cada bugfix.
3. El diff pasó por `/simplify` o `/code-review` para revisar SOLID y DRY, y los hallazgos se resolvieron.
4. Documentación al día: en `docs/Backlog.md`, la tarea marcada con ✅ y la nota `> **Hecho (AAAA-MM-DD):** …`; una entrada condensada en `docs/Changenotes.md` (de producto o de proyecto); y, si hubo una decisión que cumple los criterios de ADR, un ADR nuevo en `docs/adr/`.

## Flujo git (con humano en el bucle)

- Se trabaja directamente sobre `main`, sin ramas de feature.
- **Pide confirmación explícita al usuario antes de cada `git commit`, `git push` o cualquier operación que reescriba historial.** Muestra primero el resumen de cambios y el mensaje propuesto. Una aprobación vale solo para esa operación.
- Mensajes de commit en español con prefijo convencional: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.

## Comandos

```bash
flutter pub get
flutter run                          # requiere dispositivo/emulador Android
flutter analyze                      # lints: flutter_lints (excluye build/ y android/)
flutter test                         # todos los tests
flutter test test/router_test.dart   # un archivo
flutter test --plain-name "texto"    # un test por nombre
bash tool/verify.sh                  # puerta de calidad: analyze + test
```

Cuentas demo (sembradas en `Repository.tryPrepopulate`): `luis@gmail.com`/`123`, `honda@gmail.com`/`123`, `admin@casaracing.com`/`admin` (admin).

## Principios de código (obligatorios)

Todo código nuevo o modificado sigue **SOLID** y **DRY**. Si un cambio los viola, se refactoriza antes de darlo por terminado. En este proyecto significa:

- **S (responsabilidad única):** una pantalla solo renderiza; la lógica va al ViewModel; el acceso a datos, al repositorio. No se añaden responsabilidades nuevas a `AppController` ni a `Repository` (ver ADR 0001).
- **O / L:** se extiende con clases nuevas o inyectando colaboradores, no con más `if` por tipo. Los fakes de test deben poder sustituir a la implementación real sin romper su contrato.
- **I:** los ViewModels dependen solo de los repositorios que usan, no de un repositorio total.
- **D:** las dependencias se inyectan por constructor (como `AppController({Repository? repository})`); nada instancia su propia base de datos o cliente.
- **DRY:** antes de escribir un widget, una constante o una validación, busca si ya existe (`lib/widgets/`, `lib/theme/app_theme.dart`). Los colores y estilos salen del tema, no de literales. La configuración (URLs, teléfonos) se define en un solo sitio.

## Arquitectura

**Objetivo:** MVVM por feature con Repositories + Services, migrando de forma incremental: `docs/adr/0001-mvvm-incremental.md` y `docs/Backlog.md` (tarea 22). **Estado actual**, que se irá reemplazando:

Flujo de capas: `sqflite` → `Repository` → `AppController` (único `ChangeNotifier`) → pantallas vía `provider`.

- **`lib/data/database/app_database.dart`**: singleton de SQLite (`users`, `services`). `schemaVersion` + `_migrate` incremental: las migraciones futuras deben usar `ALTER TABLE` y conservar datos; nunca `DROP TABLE`.
- **`lib/data/repository.dart`**: acceso a datos y "reactividad" manual. No hay streams de sqflite: cada escritura llama a `_emitUsers` / `_emitAllServices`, que reemiten listas completas en `StreamController.broadcast` (incluidos los controllers por usuario de `watchServicesForUser`). Cualquier nueva operación de escritura debe reemitir igual. También contiene el estado simulado de "Firebase" (`firebaseStatus`, `triggerFirebaseSync`) y las notificaciones in-app en memoria.
- **`lib/state/app_controller.dart`**: estado global (sesión, listas, servicio seleccionado, cálculo del ciclo de aceite de 30 días, alertas). Se suscribe a los streams del repositorio y hace `notifyListeners()`. Las alertas se deduplican con `_shownAlertTitles`. Los mensajes al usuario se publican en `feedbackMessage`; `MotoApp` (`lib/app.dart`) los escucha y los muestra como `SnackBar` mediante un `ScaffoldMessenger` global. El correo se normaliza (`trim().toLowerCase()`) en el controller.
- **`lib/router/app_router.dart`**: `GoRouter` con `refreshListenable: controller`. El `redirect` gestiona auth (`/login`, `/register` ↔ `/garage`) y protege `/history/admin` para no admins. `StatefulShellRoute.indexedStack` con tres ramas (`/garage`, `/history`, `/profile`) y `MainShell` (barra inferior + `NotificationBanner`). Las pantallas de detalle no reciben parámetros por ruta: leen el estado del controller (p. ej. `selectService(s)` y luego navegar a `/history/service`). Aquí están también `openWhatsApp` / `openStore` y los canales reales de Casa Racing.
- **`lib/theme/app_theme.dart`**: tema oscuro Material 3; los valores deben coincidir con `DESIGN.md`.

## Tests

- `AppController` acepta un `Repository` inyectable; `test/support/fake_repository.dart` tiene `FakeRepository` (extiende `Repository`, en memoria, registra llamadas) y helpers `testUser()` / `testService()`.
- Los tests de router/pantallas montan `ChangeNotifierProvider.value` + `MaterialApp.router(routerConfig: createAppRouter(controller))`, fijando `controller.ready` y `controller.currentUser` directamente.
- El `Repository` real (SQLite) no tiene tests: haría falta `sqflite_common_ffi` (Backlog, tarea 18).

## Puerta de calidad

`tool/verify.sh` (`flutter analyze` + `flutter test`) es la verificación canónica. Se ejecuta en tres puntos:

| Dónde | Cómo |
|-------|------|
| Claude Code | Hook `Stop` → `.claude/hooks/stop-verify.sh` (ver `CLAUDE.md`). Bloquea el final del turno si falla. |
| Cursor | Hook `stop` en `.cursor/hooks.json` → `.cursor/hooks/stop-verify.sh`. No puede bloquear: si falla, envía un `followup_message` para que el agente lo corrija. |
| CI | `.github/workflows/verify.yml`, en cada PR y en cada push a `main`. Además exige que `lib/` y `test/` estén formateados. |

Ambos hooks son adaptadores finos sobre `tool/verify-cached.sh`, que formatea los `.dart` modificados, cachea el resultado por hash del código en `.dart_tool/verify/` y deja el log en `.dart_tool/verify/output.log`. La lógica común va en `tool/`; los adaptadores solo traducen el resultado al protocolo de cada herramienta. En CI, la versión de Flutter está fijada en `verify.yml`: actualízala cuando cambies la versión local. Plan para endurecer los lints: `docs/Backlog.md`, tarea 23.

## Skills del proyecto

Instaladas a nivel de proyecto con el CLI de skills.sh (`npx skills`), copiadas en `.claude/skills/` (Claude Code) y `.agents/skills/` (Cursor). Las versiones quedan fijadas en `skills-lock.json`; para restaurarlas: `npx skills experimental_install`. Para actualizarlas: `npx skills update -p`.

| Skill | Origen | Cuándo usarla |
|-------|--------|---------------|
| `grill-with-docs` | mattpocock/skills | Invocación manual (`/grill-with-docs`) para estresar un plan o diseño. Encadena `grilling` + `domain-modeling`. |
| `grilling` | mattpocock/skills | Dependencia de `grill-with-docs`: entrevista por rondas con respuesta recomendada. |
| `domain-modeling` | mattpocock/skills | Dependencia de `grill-with-docs`: mantiene `GLOSSARY.md` y los ADR (en `docs/adr/`). |
| `flutter-apply-architecture-best-practices` | flutter/agent-plugins | Al estructurar features o refactorizar capas (UI / lógica / datos). |
| `flutter-build-responsive-layout` | flutter/agent-plugins | Layouts que se adaptan al ancho disponible (`LayoutBuilder`, `MediaQuery.sizeOf`). |
| `flutter-fix-layout-issues` | flutter/agent-plugins | Errores de layout: overflow, altura o ancho sin límite. |
| `find-skills` | vercel-labs/skills | Buscar nuevas skills; para instalarlas, sigue la política de abajo. |

`flutter-building-layouts` (enlazada en skills.sh) ya no existe en `flutter/agent-plugins`; `flutter-fix-layout-issues` cubre esa parte. `tdd` se retiró por decisión del proyecto: los tests se exigen en la definición de terminado, sin un ciclo TDD obligatorio.

### Política para añadir skills

Una skill se ejecuta con todos los permisos del agente. Antes de instalarla:

1. Lee su `SKILL.md` y todos sus archivos, sobre todo scripts y llamadas de red. Usa `npx skills add <repo> -l` para ver qué contiene el repo.
2. Instálala solo a nivel de proyecto: `npx skills add <repo> -s <skill> -a claude-code cursor --copy -y` (nunca con `-g`).
3. Si depende de otras skills (p. ej. `grill-with-docs`), instala también esas dependencias.
4. Confirma que quedó fijada en `skills-lock.json` y añádela a la tabla de arriba.

## Restricciones de producto

- No hay backend: los mensajes de sincronización con "Firebase" en la UI son simulados. No añadas copy que prometa sincronización en la nube real ni inventes testimonios, certificaciones o assets de Casa Racing.
- La regla de 30 días del aceite y los canales (WhatsApp, URL de tienda) no están confirmados como definitivos; no los cambies sin indicación.
