#!/usr/bin/env bash
# Formatea los .dart tocados, ejecuta tool/verify.sh y cachea el resultado
# por hash del código en .dart_tool/verify/.
# Códigos de salida:
#   0 — OK (o cache de éxito con el mismo hash)
#   1 — verify falló con código nuevo
#   3 — verify sigue fallando y el hash no cambió (evita bucles en hooks)
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=wsl-flutter.sh
source "$(dirname "$0")/wsl-flutter.sh"

CACHE_DIR=".dart_tool/verify"
LOG="$CACHE_DIR/output.log"
OK_HASH="$CACHE_DIR/ok.hash"
FAIL_HASH="$CACHE_DIR/fail.hash"
mkdir -p "$CACHE_DIR"

# Hash estable del código que entra en la puerta de calidad.
hash_sources() {
  # Orden fijo: lib + test. Incluye pubspec para bumps de dependencias.
  if command -v sha256sum >/dev/null 2>&1; then
    HASH_CMD=(sha256sum)
  elif command -v shasum >/dev/null 2>&1; then
    HASH_CMD=(shasum -a 256)
  else
    echo "No hay sha256sum ni shasum" >&2
    exit 1
  fi
  {
    find lib test -type f -name '*.dart' 2>/dev/null | LC_ALL=C sort
    printf '%s\n' pubspec.yaml pubspec.lock analysis_options.yaml
  } | while IFS= read -r f; do
    [ -f "$f" ] || continue
    "${HASH_CMD[@]}" -- "$f"
  done | "${HASH_CMD[@]}" | awk '{print $1}'
}

CURRENT_HASH="$(hash_sources)"

if [ -f "$OK_HASH" ] && [ "$(cat "$OK_HASH")" = "$CURRENT_HASH" ]; then
  echo "verify: cache OK ($CURRENT_HASH)" >"$LOG"
  exit 0
fi

if [ -f "$FAIL_HASH" ] && [ "$(cat "$FAIL_HASH")" = "$CURRENT_HASH" ]; then
  echo "verify: mismo hash que el último fallo ($CURRENT_HASH); ver log anterior" | tee "$LOG"
  exit 3
fi

# Formatear solo los .dart modificados respecto a HEAD (si hay git).
format_touched() {
  local files=()
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    while IFS= read -r f; do
      [ -n "$f" ] && [ -f "$f" ] && files+=("$f")
    done < <(
      {
        git diff --name-only --diff-filter=ACMR HEAD -- 'lib/**/*.dart' 'test/**/*.dart' 2>/dev/null || true
        git ls-files --others --exclude-standard -- 'lib/**/*.dart' 'test/**/*.dart' 2>/dev/null || true
      } | LC_ALL=C sort -u
    )
  fi
  if [ ${#files[@]} -eq 0 ]; then
    # Sin cambios rastreados: formatear lib y test enteros (primer run / CI local).
    dart format lib test >/dev/null
  else
    dart format "${files[@]}" >/dev/null
  fi
}

{
  echo "=== verify $(date -Iseconds 2>/dev/null || date) hash=$CURRENT_HASH ==="
  format_touched
  # Tras formatear, el hash puede cambiar: recalcular para la cache de éxito/fallo.
  CURRENT_HASH="$(hash_sources)"
  echo "=== hash post-format=$CURRENT_HASH ==="
  set +e
  bash tool/verify.sh
  rc=$?
  set -e
  exit "$rc"
} 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}

if [ "$rc" -eq 0 ]; then
  printf '%s\n' "$CURRENT_HASH" >"$OK_HASH"
  rm -f "$FAIL_HASH"
  exit 0
fi

printf '%s\n' "$CURRENT_HASH" >"$FAIL_HASH"
rm -f "$OK_HASH"
exit 1
