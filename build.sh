#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/bootstrap.sh"
bs_bootstrap_cli "${BASH_SOURCE[0]}" "build"

case "${1:-}" in
  doctor|release|help|--help|-h)
    bs_run_cli "$@"
    ;;
  *)
    bs_run_cli build "$@"
    ;;
esac
