#!/usr/bin/env bash
# Hook Stop de Claude Code: adapta tool/verify-cached.sh al protocolo de hooks.
# exit 2 + stderr = Claude no termina el turno y recibe la salida para corregirla.
set -u
input=$(cat)
cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" || exit 0

bash tool/verify-cached.sh
rc=$?
[ $rc -eq 0 ] && exit 0

if [ $rc -eq 3 ] && printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  # Ya se bloqueó una vez y el código no cambió: dejar parar para evitar un bucle.
  printf '{"systemMessage": "Verificación (analyze/test) sigue fallando. Ver .dart_tool/verify/output.log"}\n'
  exit 0
fi

echo "tool/verify.sh falló (analyze o tests). Corrígelo antes de terminar:" >&2
tail -n 80 .dart_tool/verify/output.log >&2
exit 2
