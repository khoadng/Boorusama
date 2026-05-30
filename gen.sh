#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BOORUSAMA_ROOT="$ROOT"
BOORUSAMA_SCRIPT_NAME="gen"

source "$ROOT/scripts/toolchain.sh"
bs_resolve_toolchain

case "${1:-}" in
  i18n|booru)
    scope="$1"
    shift
    bs_run_cli "$scope" gen "$@"
    ;;
  *)
    bs_run_cli gen "$@"
    ;;
esac
