#!/usr/bin/env bash
# Puerta de calidad canónica: analyze sin avisos + tests.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=wsl-flutter.sh
source "$(dirname "$0")/wsl-flutter.sh"

flutter analyze
flutter test
