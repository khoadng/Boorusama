bs_die() {
  printf '[%s] ERROR: %s\n' "${BOORUSAMA_SCRIPT_NAME:-boorusama}" "$*" >&2
  exit 1
}

bs_log() {
  printf '[%s] %s\n' "${BOORUSAMA_SCRIPT_NAME:-boorusama}" "$*"
}

bs_resolve_executable() {
  local executable="$1"
  if [[ "$executable" == */* ]]; then
    if [[ "$executable" = /* ]]; then
      printf '%s\n' "$executable"
    else
      printf '%s\n' "$BOORUSAMA_ROOT/$executable"
    fi
  else
    printf '%s\n' "$executable"
  fi
}

bs_require_executable() {
  local executable="$1"
  local hint="$2"
  if ! command -v "$executable" >/dev/null 2>&1; then
    bs_die "$executable not found. $hint"
  fi
}

bs_resolve_toolchain() {
  local use_fvm="${BOORUSAMA_USE_FVM:-auto}"
  BOORUSAMA_USE_FVM_RESOLVED=false
  BOORUSAMA_TOOLCHAIN_SOURCE="system"

  case "$use_fvm" in
    true)
      bs_require_executable fvm "Install fvm or set BOORUSAMA_USE_FVM=false to use system Flutter/Dart."
      BOORUSAMA_USE_FVM_RESOLVED=true
      BOORUSAMA_TOOLCHAIN_SOURCE="fvm"
      export BOORUSAMA_USE_FVM=true
      ;;
    false)
      export BOORUSAMA_USE_FVM=false
      ;;
    auto)
      if [[ -f "$BOORUSAMA_ROOT/.fvmrc" ]] && command -v fvm >/dev/null 2>&1; then
        BOORUSAMA_USE_FVM_RESOLVED=true
        BOORUSAMA_TOOLCHAIN_SOURCE="fvm"
      elif [[ -f "$BOORUSAMA_ROOT/.fvmrc" ]]; then
        bs_log ".fvmrc found, but fvm is not in PATH; using system Flutter/Dart."
        export BOORUSAMA_USE_FVM=false
      fi
      ;;
    *)
      bs_die "Invalid BOORUSAMA_USE_FVM=$use_fvm. Use auto, true, or false."
      ;;
  esac

  if [[ -n "${BOORUSAMA_FLUTTER:-}" ]]; then
    local flutter_bin
    flutter_bin="$(bs_resolve_executable "$BOORUSAMA_FLUTTER")"
    bs_require_executable "$flutter_bin" "Check BOORUSAMA_FLUTTER."
    BOORUSAMA_FLUTTER_CMD=("$flutter_bin")
    BOORUSAMA_TOOLCHAIN_SOURCE="custom"
  elif [[ "$BOORUSAMA_USE_FVM_RESOLVED" == true ]]; then
    BOORUSAMA_FLUTTER_CMD=(fvm flutter)
  else
    local flutter_bin
    flutter_bin="$(bs_resolve_executable flutter)"
    bs_require_executable "$flutter_bin" "Install Flutter or set BOORUSAMA_FLUTTER."
    BOORUSAMA_FLUTTER_CMD=("$flutter_bin")
  fi

  if [[ -n "${BOORUSAMA_DART:-}" ]]; then
    local dart_bin
    dart_bin="$(bs_resolve_executable "$BOORUSAMA_DART")"
    bs_require_executable "$dart_bin" "Check BOORUSAMA_DART."
    BOORUSAMA_DART_CMD=("$dart_bin")
    BOORUSAMA_TOOLCHAIN_SOURCE="custom"
  elif [[ "$BOORUSAMA_USE_FVM_RESOLVED" == true ]]; then
    BOORUSAMA_DART_CMD=(fvm dart)
  else
    local dart_bin
    dart_bin="$(bs_resolve_executable dart)"
    bs_require_executable "$dart_bin" "Install Dart or set BOORUSAMA_DART."
    BOORUSAMA_DART_CMD=("$dart_bin")
  fi
}

bs_install_fvm() {
  if [[ "$BOORUSAMA_USE_FVM_RESOLVED" == true ]]; then
    bs_log "Installing configured FVM Flutter SDK..."
    (cd "$BOORUSAMA_ROOT" && fvm install)
  fi
}

bs_run_cli() {
  local cli_dir="$BOORUSAMA_ROOT/packages/boorusama_cli"
  cd "$cli_dir"
  exec env BOORUSAMA_ROOT="$BOORUSAMA_ROOT" "${BOORUSAMA_DART_CMD[@]}" run bin/boorusama.dart "$@"
}
