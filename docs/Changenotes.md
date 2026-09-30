# Changenotes

## [*0.0.1*] 2026-09-29
- **Seguridad:** solo los administradores pueden entrar a `/history/admin`.
- **Base de datos:** las actualizaciones de esquema ya no borran los datos (migraciones incrementales).
- **Historial:** tocar un servicio abre su detalle; borrar pide confirmación.
- **Notificaciones:** campana en el Dashboard con el historial de avisos; ya no se duplican.
- **Cuentas:** el correo no distingue mayúsculas y se valida su formato al registrarse.
- **Datos:** ya no se pierden actualizaciones del historial durante la carga inicial.
- **Tests:** 10 tests nuevos (router, controller, pantallas).
- **Docs:** nuevos `Backlog.md` y `Changenotes.md`; la carpeta pasa a llamarse `docs/`.
- **Gobernanza de agentes:** `AGENTS.md` como fuente única de reglas para Claude Code y Cursor (`CLAUDE.md` solo lo importa). Incluye SOLID/DRY obligatorios, la definición de terminado, el flujo git con confirmación humana antes de cada commit o push, y la política para instalar skills.
- **Arquitectura:** ADR `docs/adr/0001` que fija la migración incremental a MVVM, más las tareas 22 (MVVM) y 23 (`very_good_analysis`) en el backlog.
- **Puerta de calidad:** `tool/verify.sh` (analyze + test) se ejecuta automáticamente al final de cada turno de Claude Code y de Cursor, y en CI con GitHub Actions en cada PR y cada push a `main`. Todo el código queda formateado con `dart format`.
- **Skills del proyecto:** `find-skills`, `grill-with-docs` (+ `grilling`, `domain-modeling`), `flutter-apply-architecture-best-practices`, `flutter-build-responsive-layout` y `flutter-fix-layout-issues`, fijadas en `skills-lock.json`.
- **Dependencias:** paquetes de pub al día (`go_router` 18, `cupertino_icons` 2, `flutter_lints` 6 y el resto en su última versión compatible). El SDK mínimo pasa a Dart 3.12.
