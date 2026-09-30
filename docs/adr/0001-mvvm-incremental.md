---
status: accepted
---

# Migración incremental a MVVM por feature

Hoy un único `AppController` concentra sesión, listas, ciclo de aceite, alertas y feedback, y un único `Repository` mezcla acceso a SQLite, streams, notificaciones y datos semilla: ambos violan SRP y crecen con cada feature. Adoptamos la arquitectura recomendada por Flutter (skill `flutter-apply-architecture-best-practices`): Views + un ViewModel (`ChangeNotifier`) por feature en la capa UI, Repositories + Services en la capa de datos y Use Cases solo cuando la lógica se reutiliza entre ViewModels. La migración es **incremental**: cada cambio que toca una feature la mueve a la nueva estructura, en lugar de una reescritura completa que congelaría el backlog.

## Considered Options

- **Reescritura completa ahora**: descartada; bloquea el trabajo funcional pendiente (P2/P3 del backlog) y arriesga regresiones con una cobertura de tests todavía pequeña.
- **Mantener `AppController` único**: descartada; es incompatible con la regla SOLID del proyecto.

## Consequences

- Durante la transición conviven `AppController` y los nuevos ViewModels; el código nuevo no debe añadir responsabilidades a `AppController`.
- El plan de pasos está en `docs/Backlog.md` (tarea 22).
