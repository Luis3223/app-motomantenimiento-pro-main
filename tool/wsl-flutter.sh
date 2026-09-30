# Si estos scripts corren en WSL, `flutter` y `dart` apuntan al lanzador de
# shell del SDK de Windows. Ese `shared.sh` tiene finales CRLF y bash aborta
# con `$'\r': command not found` antes de analyze o test. En WSL se delega
# en los `.bat` vía cmd.exe. En Linux y en CI no cambia nada.
if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
  _wsl_cmd() {
    local bin="$1"
    shift
    # Sin comillas por argumento: WSL se las pasa literales a flutter.bat.
    cmd.exe /c "$bin $*"
  }
  flutter() { _wsl_cmd flutter.bat "$@"; }
  dart() { _wsl_cmd dart.bat "$@"; }
fi
