#!/usr/bin/env bash
# Hook stop de Cursor: adapta tool/verify-cached.sh al protocolo de hooks.
# Cursor no puede bloquear el final del turno; si falla, envía un followup_message
# para que el agente lo corrija. Si ya reintentó sin cambios, no insiste.
set -u
input=$(cat)
cd "$(dirname "$0")/../.." || { echo '{}'; exit 0; }

bash tool/verify-cached.sh
rc=$?
if [ $rc -eq 0 ] || { [ $rc -eq 3 ] && ! printf '%s' "$input" | grep -q '"loop_count"[[:space:]]*:[[:space:]]*0\b'; }; then
  echo '{}'
  exit 0
fi

echo '{"followup_message": "tool/verify.sh falló (flutter analyze o flutter test). Lee .dart_tool/verify/output.log, corrige los errores y vuelve a verificar."}'
