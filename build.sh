#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_DIR="$ROOT/packages/boorusama_cli"

if ! command -v fvm >/dev/null 2>&1; then
  echo "[ERROR] fvm not found in PATH. Boorusama uses .fvmrc for Flutter/Dart tooling." >&2
  exit 127
fi

cd "$CLI_DIR"
exec env BOORUSAMA_ROOT="$ROOT" fvm dart run bin/boorusama.dart build "$@"
