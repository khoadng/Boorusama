#!/bin/bash
set -e

#==============================================================================
# CONFIGURATION SECTION
#==============================================================================

# Colors for output (disabled in CI)
if [ "${CI:-false}" = "true" ] || [ "${GITHUB_ACTIONS:-false}" = "true" ]; then
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly NC=''
else
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m'
fi

readonly IS_CI="${CI:-false}"
readonly IS_GITHUB_ACTIONS="${GITHUB_ACTIONS:-false}"

readonly DEFAULT_OUTPUT_DIR="artifacts"
readonly DEFAULT_TARGET_FILE="lib/main.dart"
readonly FOSS_TARGET_FILE="lib/main_foss.dart"
readonly DEFAULT_BUILD_MODE="release"
readonly BUILD_BASE_DIR="build"
readonly APP_OUTPUTS_DIR="$BUILD_BASE_DIR/app/outputs"

readonly FOSS_EXCLUDED_DEPS=(
    "purchases_flutter:"
    "rate_my_app:"
    "google_api_availability:"
)

get_app_name() {
    case "$1" in
        apk) echo "$appname" ;;
        ios_dev) echo "Boorusama-DEV" ;;
        ios_prod) echo "Boorusama" ;;
        dmg) echo "boorusama" ;;
        windows) echo "$appname" ;;
        linux) echo "$appname" ;;
        *) echo "" ;;
    esac
}

get_build_path() {
    case "$1" in
        android_apk) 
            echo "$APP_OUTPUTS_DIR/flutter-apk/app-%s-%s.apk" ;;
        android_aab_dev) 
            echo "$APP_OUTPUTS_DIR/bundle/devRelease/app-dev-release.aab" ;;
        android_aab_prod) 
            echo "$APP_OUTPUTS_DIR/bundle/prodRelease/app-prod-release.aab" ;;
        ios_dev) 
            echo "$BUILD_BASE_DIR/ios/Release-dev-iphoneos/Boorusama-DEV.app" ;;
        ios_prod) 
            echo "$BUILD_BASE_DIR/ios/Release-prod-iphoneos/Boorusama.app" ;;
        macos) 
            echo "$BUILD_BASE_DIR/macos/Build/Products/Release/boorusama.app" ;;
        windows) 
            echo "$BUILD_BASE_DIR/windows/x64/runner/Release/${appname}.exe" ;;
        linux)
            echo "$BUILD_BASE_DIR/linux/x64/release/bundle"
            ;;
        *) 
            echo "" ;;
    esac
}

readonly VALID_FORMATS=("apk" "aab" "ipa" "dmg" "windows" "linux")
readonly FLAVOR_REQUIRED_FORMATS=("apk" "aab" "ipa" "dmg")

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Linux*)     PLATFORM="linux";;
        Darwin*)    PLATFORM="macos";;
        CYGWIN*|MINGW*|MSYS*) PLATFORM="windows";;
        *)          PLATFORM="unknown";;
    esac
}

#==============================================================================
# UTILITY FUNCTIONS
#==============================================================================

print_status() {
    local message="$1"
    if [ "$IS_CI" = "true" ]; then
        echo "::notice::$message"
    else
        echo -e "${GREEN}[INFO]${NC} $message"
    fi
}

print_warning() {
    local message="$1"
    if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
        echo "::warning::$message"
    else
        echo -e "${YELLOW}[WARNING]${NC} $message"
    fi
}

print_error() {
    local message="$1"
    if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
        echo "::error::$message"
    else
        echo -e "${RED}[ERROR]${NC} $message"
    fi
}

print_debug() {
    if [ "$VERBOSE" = true ] || [ "$IS_CI" = "true" ]; then
        local message="$1"
        if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
            echo "::debug::$message"
        else
            echo -e "${BLUE}[DEBUG]${NC} $message"
        fi
    fi
}

start_group() {
    local group_name="$1"
    if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
        echo "::group::$group_name"
    else
        print_status "=== $group_name ==="
    fi
}

end_group() {
    if [ "$IS_GITHUB_ACTIONS" = "true" ]; then
        echo "::endgroup::"
    fi
}

exit_with_error() {
    print_error "$1"
    exit "${2:-1}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

get_app_info() {
    if [ ! -f "pubspec.yaml" ]; then
        exit_with_error "pubspec.yaml not found. Please run this script from the Flutter project root."
    fi
    
    version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)
    appname=$(head -n 1 pubspec.yaml | cut -d ' ' -f 2)
}

#==============================================================================
# CONFIGURATION AND VALIDATION
#==============================================================================

show_usage() {
    cat << EOF
Usage: $0 <format> --flavor <flavor> [flutter-build-options] [additional-options]

Output Formats:
  apk         Build Android APK
  aab         Build Android App Bundle
  ipa         Build iOS IPA
  dmg         Build macOS DMG
  windows     Build Windows executable

Flutter Build Options (passed through):
  --release, --debug, --profile
  -f, --flavor <flavor>   (REQUIRED)
  --no-codesign (iOS only)

Additional Options:
  -s, --foss              Build FOSS version (strips non-FOSS deps for Android)
  -o, --output-dir <dir>  Output directory for artifacts (default: build/)
  -v, --verbose           Enable verbose output
  -d, --dry-run           Show what would be built without building
  -h, --help              Show this help message

CI-Specific Options:
  -c, --ci                Force CI mode (auto-detected)
  --fail-fast             Exit immediately on first error

Environment Variables:
  CI                  Set to 'true' to enable CI mode

Examples:
  $0 apk --release -f dev
  $0 aab --release -f prod --ci
  $0 ipa --release --no-codesign -f dev -s
  $0 dmg --release -f prod --output-dir artifacts/
EOF
}

init_variables() {
    FOSS_BUILD=false
    VERBOSE=${IS_CI:-false}
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    FLUTTER_ARGS=()
    FLAVOR=""
    BUILD_MODE="$DEFAULT_BUILD_MODE"
    NO_CODESIGN=false
    BACKUP_FILE=""
    BACKUP_LOCK_FILE=""
    FAIL_FAST=false
    FORCE_CI=false
}

validate_format() {
    local format="$1"
    local valid=false
    for f in "${VALID_FORMATS[@]}"; do
        if [ "$f" = "$format" ]; then
            valid=true
            break
        fi
    done
    if [ "$valid" = false ]; then
        exit_with_error "Invalid format: $format. Valid formats: ${VALID_FORMATS[*]}"
    fi
}

readonly ALLOWED_FLAVORS=("dev" "prod")

validate_build_modes() {
    local mode_count=0
    [[ " ${FLUTTER_ARGS[*]} " =~ " --release " ]] && mode_count=$((mode_count + 1))
    [[ " ${FLUTTER_ARGS[*]} " =~ " --debug " ]] && mode_count=$((mode_count + 1))
    [[ " ${FLUTTER_ARGS[*]} " =~ " --profile " ]] && mode_count=$((mode_count + 1))
    if [ $mode_count -gt 1 ]; then
        exit_with_error "Conflicting build modes specified (release/debug/profile). Please specify only one."
    fi
}

validate_flavor_value() {
    # Only require/validate flavor for formats that need it
    local format="$1"
    local valid=false
    for f in "${FLAVOR_REQUIRED_FORMATS[@]}"; do
        if [ "$f" = "$format" ]; then
            valid=true
            break
        fi
    done
    if [ "$valid" = true ]; then
        if [ -z "$FLAVOR" ]; then
            exit_with_error "Flavor is required for $format. Use --flavor <flavor>."
        fi
        local allowed=false
        for f in "${ALLOWED_FLAVORS[@]}"; do
            if [ "$f" = "$FLAVOR" ]; then
                allowed=true
                break
            fi
        done
        if [ "$allowed" = false ]; then
            exit_with_error "Invalid flavor: $FLAVOR. Allowed flavors: ${ALLOWED_FLAVORS[*]}"
        fi
    fi
}

inject_dart_define() {
    local key="$1"
    local value="$2"
    FLUTTER_ARGS+=("--dart-define=${key}=${value}")
    print_debug "Injected ${key}=${value}"
}

#==============================================================================
# SECRET ENV LOADING
#==============================================================================

SECRET_ENV_FILE=".env"

load_secret_env() {
    if [ -f "$SECRET_ENV_FILE" ]; then
        set -o allexport
        # shellcheck source=/dev/null
        source "$SECRET_ENV_FILE"
        set +o allexport
        print_status "Loaded secrets from $SECRET_ENV_FILE"
    else
        print_status "$SECRET_ENV_FILE not found, skipping secret env loading"
    fi
}

set_target_file_and_env() {
    # Only set ENV_FILE and --dart-define-from-file if FLAVOR is set
    if [ -n "$FLAVOR" ]; then
        ENV_FILE="env/${FLAVOR}.json"
        FLUTTER_ARGS+=("--dart-define-from-file" "$ENV_FILE")
    fi
    if [ "$FOSS_BUILD" = true ]; then
        TARGET_FILE="$FOSS_TARGET_FILE"
    else
        TARGET_FILE="$DEFAULT_TARGET_FILE"
    fi
    FLUTTER_ARGS+=("-t" "$TARGET_FILE")

    # Inject Git commit and branch as Dart defines
    if command_exists git; then
        local git_commit git_branch
        git_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
        git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
        inject_dart_define "GIT_COMMIT" "$git_commit"
        inject_dart_define "GIT_BRANCH" "$git_branch"
    else
        print_warning "git not found, skipping GIT_COMMIT and GIT_BRANCH dart-defines"
    fi

    # Inject build timestamp
    local build_timestamp flutter_version
    build_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    inject_dart_define "BUILD_TIMESTAMP" "$build_timestamp"

    # Inject IS_FOSS_BUILD
    inject_dart_define "IS_FOSS_BUILD" "$FOSS_BUILD"
    
    # Inject cronetHttpNoPlay for FOSS Android builds
    if [ "$FOSS_BUILD" = true ] && { [ "$FORMAT" = "apk" ] || [ "$FORMAT" = "aab" ]; }; then
        inject_dart_define "cronetHttpNoPlay" "true"
    fi

    # Inject RevenueCat keys from secret env if needed
    if [ "$FOSS_BUILD" = false ] && [ "$FLAVOR" = "prod" ]; then
        if [ "$FORMAT" = "aab" ] || [ "$FORMAT" = "apk" ]; then
            if [ -z "$REVENUECAT_GOOGLE_API_KEY" ]; then
                exit_with_error "REVENUECAT_GOOGLE_API_KEY is required for prod Android builds. Set it in $SECRET_ENV_FILE"
            fi
            inject_dart_define "REVENUECAT_GOOGLE_API_KEY" "$REVENUECAT_GOOGLE_API_KEY"
        fi
        if [ "$FORMAT" = "ipa" ]; then
            if [ -z "$REVENUECAT_APPLE_API_KEY" ]; then
                exit_with_error "REVENUECAT_APPLE_API_KEY is required for prod iOS builds. Set it in $SECRET_ENV_FILE"
            fi
            inject_dart_define "REVENUECAT_APPLE_API_KEY" "$REVENUECAT_APPLE_API_KEY"
        fi
    fi
}

# Check .env (env var) for prod keys
validate_env_api_key() {
    local key_name="$1"
    local key_label="$2"
    local value="${!key_name}"
    if [ -z "$value" ]; then
        exit_with_error "$key_label is missing or empty in .env"
    fi
}

validate_prod_environment() {
    if [ "$FOSS_BUILD" = false ] && [ "$FLAVOR" = "prod" ]; then
        if [ "$FORMAT" = "aab" ] || [ "$FORMAT" = "apk" ]; then
            validate_env_api_key "REVENUECAT_GOOGLE_API_KEY" "REVENUECAT_GOOGLE_API_KEY"
        fi
        if [ "$FORMAT" = "ipa" ]; then
            validate_env_api_key "REVENUECAT_APPLE_API_KEY" "REVENUECAT_APPLE_API_KEY"
        fi
    fi
}

validate_output_dir() {
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR" 2>/dev/null || exit_with_error "Failed to create output directory: $OUTPUT_DIR"
    fi
    if [ ! -w "$OUTPUT_DIR" ]; then
        exit_with_error "Output directory is not writable: $OUTPUT_DIR"
    fi
}

warn_pubspec_backup() {
    local backup_file backup_lock_file
    backup_file=$(ls pubspec.yaml.backup.* 2>/dev/null | head -n1)
    backup_lock_file=$(ls pubspec.lock.backup.* 2>/dev/null | head -n1)

    if [ -n "$backup_file" ] || [ -n "$backup_lock_file" ]; then
        if [ -n "$backup_file" ] && [ -n "$backup_lock_file" ]; then
            print_warning "Found leftover pubspec backups ($backup_file, $backup_lock_file). Previous run may not have cleaned up. Consider restoring them if needed."
        elif [ -n "$backup_file" ]; then
            print_warning "Found leftover pubspec backup ($backup_file). Previous run may not have cleaned up. Consider restoring it if needed."
        else
            print_warning "Found leftover pubspec.lock backup ($backup_lock_file). Previous run may not have cleaned up. Consider restoring it if needed."
        fi
    fi
}

#==============================================================================
# ARGUMENT PARSING
#==============================================================================

parse_arguments() {
    if [ $# -eq 0 ]; then
        print_error "Output format argument is required."
        show_usage
        exit 1
    fi

    FORMAT=$1
    shift

    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--foss)
                FOSS_BUILD=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -o|--output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -f|--flavor)
                FLAVOR="$2"
                # Only add --flavor to FLUTTER_ARGS if the format supports it
                for f in "${FLAVOR_REQUIRED_FORMATS[@]}"; do
                    if [ "$FORMAT" = "$f" ]; then
                        FLUTTER_ARGS+=("--flavor" "$2")
                        break
                    fi
                done
                shift 2
                ;;
            --release|--debug|--profile)
                BUILD_MODE="${1#--}"
                FLUTTER_ARGS+=("$1")
                shift
                ;;
            --no-codesign)
                NO_CODESIGN=true
                FLUTTER_ARGS+=("$1")
                shift
                ;;
            -c|--ci)
                FORCE_CI=true
                shift
                ;;
            --fail-fast)
                FAIL_FAST=true
                set -e
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                FLUTTER_ARGS+=("$1")
                shift
                ;;
        esac
    done

    if [ "$FORCE_CI" = "true" ]; then
        export CI=true
        IS_CI=true
    fi
}

#==============================================================================
# FOSS BUILD HANDLING
#==============================================================================

create_pubspec_backup() {
    if [ "$FOSS_BUILD" = true ]; then
        local timestamp="$(date +%s).$$"
        BACKUP_FILE="pubspec.yaml.backup.$timestamp"
        BACKUP_LOCK_FILE="pubspec.lock.backup.$timestamp"

        cp pubspec.yaml "$BACKUP_FILE"
        if [ -f "pubspec.lock" ]; then
            cp pubspec.lock "$BACKUP_LOCK_FILE"
            print_status "Created backup of pubspec.yaml and pubspec.lock for FOSS build"
        else
            print_status "Created backup of pubspec.yaml for FOSS build (no pubspec.lock found)"
        fi
    fi
}

restore_pubspec() {
    if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
        mv "$BACKUP_FILE" pubspec.yaml

        if [ -n "$BACKUP_LOCK_FILE" ] && [ -f "$BACKUP_LOCK_FILE" ]; then
            mv "$BACKUP_LOCK_FILE" pubspec.lock
            print_status "Restored original pubspec.yaml and pubspec.lock"
        else
            print_status "Restored original pubspec.yaml"
            flutter pub get > /dev/null 2>&1
        fi
    fi
}

create_temp_file() {
    local template="$1"
    local temp_file
    temp_file=$(mktemp "${template}.XXXXXX") || exit_with_error "Failed to create temp file"
    echo "$temp_file"
}

prepare_foss_build() {
    local pubspec_file="pubspec.yaml"
    local temp_file
    temp_file=$(create_temp_file "pubspec.yaml")

    # Trap to clean up temp_file on any exit from this function
    trap 'rm -f "$temp_file" "$temp_file.bak" 2>/dev/null || true' RETURN

    print_status "Preparing FOSS build - removing non-FOSS dependencies..."

    if [ ! -f "$pubspec_file" ]; then
        exit_with_error "pubspec.yaml not found"
    fi

    cp "$pubspec_file" "$temp_file"

    for dep in "${FOSS_EXCLUDED_DEPS[@]}"; do
        if grep -q "$dep" "$temp_file"; then
            print_debug "Removing dependency: $dep"
            sed -i.bak "/$dep/d" "$temp_file"
            rm -f "$temp_file.bak" 2>/dev/null || true
        else
            print_debug "Dependency not found (already clean): $dep"
        fi
    done

    mv "$temp_file" "$pubspec_file"

    print_status "Getting FOSS dependencies..."
    if ! flutter pub get; then
        exit_with_error "Failed to get FOSS dependencies"
    fi
}

copy_and_track_artifact() {
    local source="$1"
    local target="$2"
    local type="$3"
    
    if [ ! -f "$source" ]; then
        exit_with_error "$type not found at: $source"
    fi
    
    if [ "$OUTPUT_DIR" != "build" ]; then
        cp "$source" "$target"
        add_build_artifact "$target" "$type"
        print_status "$type copied to: $target"
    else
        add_build_artifact "$source" "$type"
        print_status "$type created: $source"
    fi
}

execute_flutter_build() {
    local platform="$1"
    local verbose_flag=""
    
    if [ "$IS_CI" = "true" ]; then
        verbose_flag="--verbose"
    fi
    
    print_status "Building $platform..."
    if ! flutter build "$platform" "${FLUTTER_ARGS[@]}" $verbose_flag; then
        exit_with_error "Flutter build failed for $platform"
    fi
}

require_platform() {
    local required="$1"
    if [ "$PLATFORM" != "$required" ]; then
        exit_with_error "$2"
    fi
}

#==============================================================================
# FORMAT-SPECIFIC BUILD FUNCTIONS
#==============================================================================

build_apk() {
    start_group "Building Android APK"
    execute_flutter_build apk
    
    local apk_source
    if [ -n "$FLAVOR" ]; then
        apk_source="build/app/outputs/flutter-apk/app-$FLAVOR-$BUILD_MODE.apk"
    else
        apk_source="build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
    fi
    
    local apk_name
    if [ "$FOSS_BUILD" = true ]; then
        apk_name="$appname-$version-${FLAVOR:-universal}-foss.apk"
    else
        apk_name="$appname-$version-${FLAVOR:-universal}.apk"
    fi
    local apk_target="$OUTPUT_DIR/$apk_name"

    copy_and_track_artifact "$apk_source" "$apk_target" "APK"
    
    end_group "Building Android APK"
}

build_aab() {
    start_group "Building Android App Bundle"
    execute_flutter_build appbundle
    
    local aab_source aab_name aab_target
    
    case "$FLAVOR" in
        dev)
            aab_source=$(get_build_path "android_aab_dev")
            aab_name="$appname-$version-dev.aab"
            ;;
        prod)
            aab_source=$(get_build_path "android_aab_prod")
            aab_name="$appname-$version.aab"
            ;;
        *)
            print_warning "No specific flavor handling for app bundle"
            return
            ;;
    esac

    local aab_target="$OUTPUT_DIR/$aab_name"
    copy_and_track_artifact "$aab_source" "$aab_target" "AAB"
    
    end_group "Building Android App Bundle"
}

build_ipa() {
    require_platform "macos" "iOS builds are only supported on macOS."

    print_status "Building iOS IPA..."
    execute_flutter_build ios
    
    case "$FLAVOR" in
        dev|prod)
            ;;
        *)
            exit_with_error "iOS build requires flavor (dev or prod)"
            ;;
    esac
    
    print_status "Creating IPA package..."
    mkdir -p build/Payload
    
    local app_path ipa_name
    if [ "$FLAVOR" = "dev" ]; then
        app_path=$(get_build_path "ios_dev")
        ipa_name="${appname}_${version}-dev.ipa"
    else
        app_path=$(get_build_path "ios_prod")
        ipa_name="${appname}_${version}.ipa"
    fi
    
    cp -r "$app_path" build/Payload/
    
    cd build
    zip -rq "$ipa_name" Payload
    rm -rf Payload
    cd ..
    
    local ipa_source="build/$ipa_name"
    local ipa_target="$OUTPUT_DIR/$ipa_name"
    copy_and_track_artifact "$ipa_source" "$ipa_target" "IPA"
}

build_dmg() {
    require_platform "macos" "DMG builds are only supported on macOS."

    print_status "Building macOS DMG..."
    
    if ! command_exists create-dmg; then
        exit_with_error "create-dmg not found. Install with: brew install create-dmg"
    fi
    
    execute_flutter_build macos

    print_status "Creating DMG package..."
    local macos_app=$(get_app_name "dmg")
    cp -r "$(get_build_path "macos")" "build/${macos_app}.app"
    
    local dmg_name
    case "$FLAVOR" in
        dev)
            dmg_name="${appname}-${version}-dev.dmg"
            ;;
        prod)
            dmg_name="${appname}-${version}.dmg"
            ;;
        *)
            dmg_name="${appname}-${version}.dmg"
            ;;
    esac
    
    create-dmg --hdiutil-quiet "build/$dmg_name" "build/${macos_app}.app"
    rm -rf "build/${macos_app}.app"
    
    local dmg_source="build/$dmg_name"
    local dmg_target="$OUTPUT_DIR/$dmg_name"
    copy_and_track_artifact "$dmg_source" "$dmg_target" "DMG"
}

build_windows() {
    require_platform "windows" "Windows builds are only supported on Windows."

    if ! command_exists zip; then
        exit_with_error "zip command not found. Please install zip (e.g., 'choco install zip' or add it to your PATH)."
    fi

    start_group "Building Windows Executable"
    execute_flutter_build windows

    local exe_name zip_name
    if [ "$FOSS_BUILD" = true ]; then
        exe_name="${appname}-${version}-foss.exe"
        zip_name="${appname}-${version}-foss.zip"
    else
        exe_name="${appname}-${version}.exe"
        zip_name="${appname}-${version}.zip"
    fi
    # Use get_build_path to determine the release directory dynamically
    local exe_path
    exe_path=$(get_build_path "windows")
    local release_dir
    release_dir=$(dirname "$exe_path")
    local zip_source="$release_dir"
    local zip_target="$OUTPUT_DIR/$zip_name"

    # Zip the entire Release folder for distribution
    if [ -d "$release_dir" ]; then
        (cd "$release_dir" && zip -r "../../../../../$zip_target" .)
        add_build_artifact "$zip_target" "Windows ZIP"
        print_status "Windows build folder zipped to: $zip_target"
    else
        exit_with_error "Release directory not found: $release_dir"
    fi

    end_group "Building Windows Executable"
}

build_linux() {
    # Placeholder for Linux build implementation
    print_status "Linux build is not yet implemented."
}

#==============================================================================
# BUILD EXECUTION
#==============================================================================

execute_build() {
    case $FORMAT in
        apk)
            build_apk
            ;;
        aab)
            build_aab
            ;;
        ipa)
            build_ipa
            ;;
        dmg)
            build_dmg
            ;;
        windows)
            build_windows
            ;;
        linux)
            build_linux
            ;;
    esac
}

#==============================================================================
# MAIN EXECUTION LOGIC
#==============================================================================

cleanup_on_exit() {
    local exit_code=$?
    restore_pubspec

    # No need to clean up temp files here; handled in prepare_foss_build

    exit $exit_code
}

main() {
    BUILD_START_TIME=$(date +%s)

    # Set trap early to ensure cleanup on any exit
    trap cleanup_on_exit INT TERM EXIT

    detect_platform

    init_variables
    get_app_info

    warn_pubspec_backup

    parse_arguments "$@"

    validate_format "$FORMAT"
    validate_build_modes
    validate_flavor_value "$FORMAT" 

    load_secret_env

    set_target_file_and_env
    validate_output_dir
    validate_prod_environment

    print_status "Building $appname version $version as $FORMAT ($BUILD_MODE)"
    print_debug "Target file: $TARGET_FILE"
    print_debug "Flavor: ${FLAVOR:-none}"
    print_debug "FOSS build: $FOSS_BUILD"
    print_debug "CI mode: $IS_CI"

    # Always run gen.sh script before building
    if [ -x "./gen.sh" ]; then
        print_status "Generating code..."
        if ! ./gen.sh; then
            exit_with_error "Code generation failed"
        fi
        print_status "Code generation completed."
    else
        print_warning "gen.sh script not found or not executable, skipping code generation"
    fi

    mkdir -p "$OUTPUT_DIR"
    create_pubspec_backup

    if [ "$FOSS_BUILD" = true ]; then
        if ! prepare_foss_build; then
            exit_with_error "FOSS build preparation failed"
        fi
    fi

    execute_build

    show_build_summary
}

add_build_artifact() {
    local artifact_path="$1"
    local artifact_type="$2"
    
    if [ -f "$artifact_path" ]; then
        BUILD_ARTIFACTS+=("$artifact_type:$artifact_path")
    fi
}

show_build_summary() {
    local build_end_time=$(date +%s)
    local build_duration=$((build_end_time - BUILD_START_TIME))
    local duration_formatted
    
    if [ $build_duration -ge 60 ]; then
        local minutes=$((build_duration / 60))
        local seconds=$((build_duration % 60))
        duration_formatted="${minutes}m ${seconds}s"
    else
        duration_formatted="${build_duration}s"
    fi
    
    echo
    print_status "=== BUILD SUMMARY ==="
    echo "App: $appname v$version"
    echo "Format: $FORMAT ($BUILD_MODE)"
    echo "Flavor: ${FLAVOR:-none}"
    echo "FOSS: $FOSS_BUILD"
    echo "Duration: $duration_formatted"
    echo
    
    if [ ${#BUILD_ARTIFACTS[@]} -gt 0 ]; then
        echo "Artifacts:"
        for artifact in "${BUILD_ARTIFACTS[@]}"; do
            IFS=':' read -r type path <<< "$artifact"
            echo "  $type: $path"
        done
        echo
    fi
    
    print_status "Build completed successfully!"
}

main "$@"
