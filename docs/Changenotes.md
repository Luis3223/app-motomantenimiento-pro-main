# Changenotes

## [*0.0.3*] 2026-09-30
- **Seguridad:** las contraseñas se guardan con hash PBKDF2-SHA256 y sal; las cuentas existentes se convierten al actualizar (esquema v3).
- **Seguridad:** las cuentas demo (`admin` / `admin`, etc.) solo se crean en debug; en release no existen.
- **Sesión:** la sesión se conserva al cerrar la app y se borra al cerrar sesión.
- **Dependencias:** `crypto`.
- **Tests:** 9 tests nuevos (hasher con vector RFC 7914, sesión persistente).

## [*0.0.2*] 2026-09-30
- **Veracidad:** la app ya no afirma sincronizar con Firebase; los textos dicen que los datos se guardan en el dispositivo y se quitó el indicador del Dashboard.
- **Registro:** año y VIN opcionales; ya no se inventan. El perfil los muestra.
- **Servicios:** se rechaza el kilometraje negativo y se avisa si es menor que el de un servicio anterior.
- **Detalle técnico:** muestra kilometraje, número y fecha del último servicio reales; antes salía vacío.
- **Datos:** fecha ilegible del aceite muestra "Fecha inválida"; semilla con km coherente.
- **Alta de servicio:** si el guardado falla (p. ej. km inválido), la pantalla ya no vuelve al historial.
- **Limpieza:** eliminados `FirebaseSyncStatus`, `forceSync` y los timers de sincronización simulada.
- **Tests:** 7 tests nuevos en `app_controller_test.dart`.

## [*0.0.1*] 2026-09-29
- **Seguridad:** solo los administradores pueden entrar a `/history/admin`.
- **Base de datos:** las actualizaciones de esquema ya no borran los datos (migraciones incrementales).
- **Historial:** tocar un servicio abre su detalle; borrar pide confirmación.
- **Notificaciones:** campana en el Dashboard con el historial de avisos; ya no se duplican.
- **Cuentas:** el correo no distingue mayúsculas y se valida su formato al registrarse.
- **Datos:** ya no se pierden actualizaciones del historial durante la carga inicial.
- **Tests:** 11 tests nuevos (router, controller, pantallas) y un `FakeRepository` en memoria para los tests.
- **Docs:** nuevos `Backlog.md` y `Changenotes.md`; la carpeta pasa a llamarse `docs/`.
- **Gobernanza de agentes:** `AGENTS.md` como fuente única de reglas para Claude Code y Cursor (`CLAUDE.md` solo lo importa). Incluye SOLID/DRY obligatorios, la definición de terminado, el flujo git con confirmación humana antes de cada commit o push, y la política para instalar skills.
- **Arquitectura:** ADR `docs/adr/0001` que fija la migración incremental a MVVM, más las tareas 22 (MVVM) y 23 (`very_good_analysis`) en el backlog.
- **Puerta de calidad:** `tool/verify.sh` (analyze + test) se ejecuta automáticamente al final de cada turno de Claude Code y de Cursor, y en CI con GitHub Actions en cada PR y cada push a `main`. Todo el código queda formateado con `dart format`.
- **Skills del proyecto:** `find-skills`, `grill-with-docs` (+ `grilling`, `domain-modeling`), `flutter-apply-architecture-best-practices`, `flutter-build-responsive-layout` y `flutter-fix-layout-issues`, fijadas en `skills-lock.json`.
- **Dependencias:** paquetes de pub al día (`go_router` 18, `cupertino_icons` 2, `flutter_lints` 6 y el resto en su última versión compatible). El SDK mínimo pasa a Dart 3.12.
- **Build Android:** el JDK ya no va en una ruta fija del repo; Gradle usa la variable de entorno `JAVA_HOME` de cada máquina.
- **Build Android:** Gradle 9.3.1, Android Gradle Plugin 9.1.0 y Kotlin 2.4.0, las versiones de la plantilla de Flutter 3.47. Kotlin integrado (`android.builtInKotlin=true`) y el NDK que trae Flutter (`flutter.ndkVersion`). Se mantiene `android.newDsl=false`.
- **Puerta de calidad en WSL:** `tool/verify.sh` llama a `flutter.bat` y `dart.bat` cuando corre bajo WSL, porque el `shared.sh` del SDK de Windows trae finales CRLF y bash aborta antes de analyze o test.
