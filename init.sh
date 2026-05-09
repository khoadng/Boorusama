#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BOORUSAMA_ROOT="$ROOT"
CLI_DIR="$ROOT/packages/boorusama_cli"
BOORUSAMA_SCRIPT_NAME="init"

source "$ROOT/scripts/toolchain.sh"

if (($# > 0)); then
  bs_die "init.sh does not accept arguments."
fi

bs_resolve_toolchain
bs_log "Toolchain: $BOORUSAMA_TOOLCHAIN_SOURCE (${BOORUSAMA_FLUTTER_CMD[*]}, ${BOORUSAMA_DART_CMD[*]})"

bs_install_fvm

bs_log "Getting app dependencies..."
(cd "$ROOT" && "${BOORUSAMA_FLUTTER_CMD[@]}" pub get)

bs_log "Getting CLI dependencies..."
(cd "$CLI_DIR" && "${BOORUSAMA_DART_CMD[@]}" pub get)

bs_log "Generating code..."
"$ROOT/gen.sh"

bs_log "Done."
