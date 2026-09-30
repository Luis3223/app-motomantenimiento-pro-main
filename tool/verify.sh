#!/usr/bin/env bash
# Puerta de calidad canónica: analyze sin avisos + tests.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter analyze
flutter test
