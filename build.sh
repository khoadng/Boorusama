#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_DIR="$ROOT/packages/boorusama_cli"

resolve_executable() {
  local executable="$1"
  if [[ "$executable" == */* ]]; then
    if [[ "$executable" = /* ]]; then
      printf '%s\n' "$executable"
    else
      printf '%s\n' "$ROOT/$executable"
    fi
  else
    printf '%s\n' "$executable"
  fi
}

USE_FVM="${BOORUSAMA_USE_FVM:-auto}"
RUN_CMD=()

if [[ "$USE_FVM" == "false" ]]; then
  DART_BIN="$(resolve_executable "${BOORUSAMA_DART:-dart}")"
  if ! command -v "$DART_BIN" >/dev/null 2>&1; then
    echo "[ERROR] $DART_BIN not found in PATH. Install Dart or unset BOORUSAMA_USE_FVM to use fvm." >&2
    exit 127
  fi
  RUN_CMD=("$DART_BIN" run)
elif command -v fvm >/dev/null 2>&1; then
  RUN_CMD=(fvm dart run)
elif [[ "$USE_FVM" == "true" ]]; then
  echo "[ERROR] fvm not found in PATH. Install fvm or set BOORUSAMA_USE_FVM=false to use system Dart/Flutter." >&2
  exit 127
else
  DART_BIN="$(resolve_executable "${BOORUSAMA_DART:-dart}")"
  if ! command -v "$DART_BIN" >/dev/null 2>&1; then
    echo "[ERROR] Neither fvm nor $DART_BIN was found in PATH." >&2
    exit 127
  fi
  echo "[WARN] fvm not found in PATH; using $DART_BIN. Set BOORUSAMA_USE_FVM=true to require fvm." >&2
  export BOORUSAMA_USE_FVM=false
  RUN_CMD=("$DART_BIN" run)
fi

cd "$CLI_DIR"

case "${1:-}" in
  doctor|release|help|--help|-h)
    exec env BOORUSAMA_ROOT="$ROOT" "${RUN_CMD[@]}" bin/boorusama.dart "$@"
    ;;
  *)
    exec env BOORUSAMA_ROOT="$ROOT" "${RUN_CMD[@]}" bin/boorusama.dart build "$@"
    ;;
esac
