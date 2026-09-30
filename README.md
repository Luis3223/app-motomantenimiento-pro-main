# MotoMantenimiento Pro

App Flutter (Android) para seguimiento de mantenimiento de motos — partner **Casa Racing**.

## Ejecutar

```bash
flutter pub get
flutter run
```

## Para generar APK

Segun el caso:

```bash
flutter build apk --release
flutter build apk --debug
```
## Cuentas demo

| Email | Password | Rol |
|-------|----------|-----|
| `luis@gmail.com` | `123` | usuario |
| `honda@gmail.com` | `123` | usuario |
| `admin@casaracing.com` | `admin` | admin |

## Stack

- Flutter + Material 3
- `sqflite` (SQLite local)
- `provider` + `go_router`
- Sync / push simulados (sin Firebase real)
