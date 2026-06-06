bs_bootstrap_root() {
  cd "$(dirname "$1")" && pwd
}

bs_bootstrap_cli() {
  local script_path="$1"
  local script_name="$2"

  ROOT="$(bs_bootstrap_root "$script_path")"
  export BOORUSAMA_ROOT="$ROOT"
  export BOORUSAMA_SCRIPT_NAME="$script_name"

  source "$ROOT/scripts/toolchain.sh"
  bs_resolve_toolchain
}
