#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/bootstrap.sh"
bs_bootstrap_cli "${BASH_SOURCE[0]}" "release"
bs_run_cli release all "$@"
