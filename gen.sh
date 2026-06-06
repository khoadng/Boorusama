#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/bootstrap.sh"
bs_bootstrap_cli "${BASH_SOURCE[0]}" "gen"

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
