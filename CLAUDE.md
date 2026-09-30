# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

@AGENTS.md

## Específico de Claude Code

- **Hook `Stop`** (`.claude/settings.json` → `.claude/hooks/stop-verify.sh`): al final de cada turno ejecuta `tool/verify-cached.sh`. Si falla, el turno no termina (exit 2) y recibes la salida: corrígelo. Si vuelve a fallar sin que el código haya cambiado, deja terminar y avisa al usuario con un `systemMessage`.
- `.claude/settings.json` está versionado y contiene la gobernanza compartida. Lo personal va en `.claude/settings.local.json`, que no se versiona (ahí están los hooks de impeccable).
