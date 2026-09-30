# MotoMantenimiento Pro

App Flutter (Android) para seguimiento de mantenimiento de motos — partner **Casa Racing**.

## Ejecutar

```bash
flutter pub get
flutter run
```

## Para generar APK

El proyecto pide JDK 17. La ruta no va en el repositorio: Gradle la toma de la variable de entorno `JAVA_HOME` de cada máquina. No añadas `org.gradle.java.home` en `android/gradle.properties`.

1. Instala un JDK 17 y anota su carpeta (la que contiene `bin`).
2. Defínela en Windows, una sola vez por usuario. Cambia la ruta por la de tu equipo:

```powershell
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\ruta\al\jdk-17", "User")
```

3. Cierra la terminal y abre otra, para que recoja la variable.
4. Comprueba que apunta a tu JDK:

```powershell
echo $env:JAVA_HOME
java -version
```

5. Genera el APK:

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
