#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BOORUSAMA_ROOT="$ROOT"
BOORUSAMA_SCRIPT_NAME="build"

source "$ROOT/scripts/toolchain.sh"
bs_resolve_toolchain

case "${1:-}" in
  doctor|release|help|--help|-h)
    bs_run_cli "$@"
    ;;
  *)
    bs_run_cli build "$@"
    ;;
esac
