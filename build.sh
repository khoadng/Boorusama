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

get_platform_config() {
    case "$1" in
        apk) echo "apk" ;;
        aab) echo "appbundle" ;;
        ipa) echo "ios" ;;
        dmg) echo "macos" ;;
        *) echo "" ;;
    esac
}

get_app_name() {
    case "$1" in
        apk) echo "$appname" ;;
        ios_dev) echo "Boorusama-DEV" ;;
        ios_prod) echo "Boorusama" ;;
        dmg) echo "boorusama" ;;
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
        *) 
            echo "" ;;
    esac
}

readonly VALID_FORMATS=("apk" "aab" "ipa" "dmg")

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
    DRY_RUN=false
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    FLUTTER_ARGS=()
    FLAVOR=""
    BUILD_MODE="$DEFAULT_BUILD_MODE"
    NO_CODESIGN=false
    BACKUP_FILE=""
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
    [[ " ${FLUTTER_ARGS[*]} " =~ " --release " ]] && ((mode_count++))
    [[ " ${FLUTTER_ARGS[*]} " =~ " --debug " ]] && ((mode_count++))
    [[ " ${FLUTTER_ARGS[*]} " =~ " --profile " ]] && ((mode_count++))
    if [ $mode_count -gt 1 ]; then
        exit_with_error "Conflicting build modes specified (release/debug/profile). Please specify only one."
    fi
}

validate_flavor_value() {
    if [ -z "$FLAVOR" ]; then
        exit_with_error "Flavor is required. Use --flavor <flavor>."
    fi
    local valid=false
    for f in "${ALLOWED_FLAVORS[@]}"; do
        if [ "$f" = "$FLAVOR" ]; then
            valid=true
            break
        fi
    done
    if [ "$valid" = false ]; then
        exit_with_error "Invalid flavor: $FLAVOR. Allowed flavors: ${ALLOWED_FLAVORS[*]}"
    fi
}

inject_dart_define() {
    local key="$1"
    local value="$2"
    FLUTTER_ARGS+=("--dart-define=${key}=${value}")
    print_debug "Injected ${key}=${value}"
}

set_target_file_and_env() {
    ENV_FILE="env/${FLAVOR}.json"
    FLUTTER_ARGS+=("--dart-define-from-file" "$ENV_FILE")
    if [ "$FOSS_BUILD" = true ]; then
        TARGET_FILE="$FOSS_TARGET_FILE"
    else
        TARGET_FILE="$DEFAULT_TARGET_FILE"
    fi
    FLUTTER_ARGS+=("-t" "$TARGET_FILE")

    # Inject Git commit and branch as Dart defines
    if command_exists git; then
        local git_commit git_branch
        git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
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


    # Inject Flutter version
    if command_exists flutter; then
        flutter_version=$(flutter --version 2>/dev/null | head -n 1 | awk '{print $2}')
    else
        flutter_version="unknown"
    fi
    inject_dart_define "FLUTTER_VERSION" "$flutter_version"

    # Inject Dart version
    local dart_version
    if command_exists dart; then
        dart_version=$(dart --version 2>&1 | awk '{print $4}')
    else
        dart_version="unknown"
    fi
    inject_dart_define "DART_VERSION" "$dart_version"

    # Inject IS_FOSS_BUILD
    inject_dart_define "IS_FOSS_BUILD" "$FOSS_BUILD"
}

validate_env_api_key() {
    local key_name="$1"
    local env_file="$2"
    local key_label="$3"
    if command_exists jq; then
        local api_key
        api_key=$(jq -r ".${key_name} // empty" "$env_file" 2>/dev/null)
        if [ -z "$api_key" ] || [ "$api_key" = "null" ]; then
            exit_with_error "$key_label is missing or empty in $env_file"
        fi
        print_debug "$key_label validation passed"
    else
        exit_with_error "jq not found, but $key_label validation is required. Please install jq."
    fi
}

validate_prod_environment() {
    if [ "$FLAVOR" = "prod" ] && [ -n "$ENV_FILE" ]; then
        if [ "$FORMAT" = "aab" ]; then
            validate_env_api_key "REVENUECAT_GOOGLE_API_KEY" "$ENV_FILE" "REVENUECAT_GOOGLE_API_KEY"
        fi
        if [ "$FORMAT" = "ipa" ]; then
            validate_env_api_key "REVENUECAT_APPLE_API_KEY" "$ENV_FILE" "REVENUECAT_APPLE_API_KEY"
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
    local backup_file
    backup_file=$(ls pubspec.yaml.backup.* 2>/dev/null | head -n1)
    if [ -n "$backup_file" ]; then
        print_warning "Found leftover pubspec backup ($backup_file). Previous run may not have cleaned up. Consider restoring it if needed."
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
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -f|--flavor)
                FLAVOR="$2"
                FLUTTER_ARGS+=("--flavor" "$2")
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
        BACKUP_FILE="pubspec.yaml.backup.$(date +%s).$$"
        cp pubspec.yaml "$BACKUP_FILE"
        print_status "Created backup of pubspec.yaml for FOSS build"
    fi
}

restore_pubspec() {
    if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
        mv "$BACKUP_FILE" pubspec.yaml
        print_status "Restored original pubspec.yaml"
        flutter pub get > /dev/null 2>&1
    fi
}

prepare_foss_build() {
    local pubspec_file="pubspec.yaml"
    local temp_file="pubspec.yaml.tmp"
    
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

#==============================================================================
# FORMAT-SPECIFIC BUILD FUNCTIONS
#==============================================================================

build_apk() {
    start_group "Building Android APK"
    
    print_status "Building Android APK..."
    if [ "$IS_CI" = "true" ]; then
        flutter build apk "${FLUTTER_ARGS[@]}" --verbose
    else
        flutter build apk "${FLUTTER_ARGS[@]}"
    fi
    
    local apk_source
    if [ -n "$FLAVOR" ]; then
        apk_source="build/app/outputs/flutter-apk/app-$FLAVOR-$BUILD_MODE.apk"
    else
        apk_source="build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
    fi
    
    if [ -f "$apk_source" ]; then
        local apk_name
        if [ "$FOSS_BUILD" = true ]; then
            apk_name="$appname-$version-${FLAVOR:-universal}-foss.apk"
        else
            apk_name="$appname-$version-${FLAVOR:-universal}.apk"
        fi
        
        if [ "$OUTPUT_DIR" != "build" ]; then
            cp "$apk_source" "$OUTPUT_DIR/$apk_name"
            add_build_artifact "$OUTPUT_DIR/$apk_name" "APK"
            print_status "APK copied to: $OUTPUT_DIR/$apk_name"
        else
            add_build_artifact "$apk_source" "APK"
            print_status "APK created: $apk_source"
        fi
    else
        exit_with_error "APK not found at expected location: $apk_source"
    fi
    
    end_group "Building Android APK"
}

build_aab() {
    start_group "Building Android App Bundle"
    
    print_status "Building Android App Bundle..."
    if [ "$IS_CI" = "true" ]; then
        flutter build appbundle "${FLUTTER_ARGS[@]}" --verbose
    else
        flutter build appbundle "${FLUTTER_ARGS[@]}"
    fi
    
    local aab_source aab_target
    
    case "$FLAVOR" in
        dev)
            aab_source=$(get_build_path "android_aab_dev")
            aab_target="build/app/outputs/bundle/devRelease/$appname-$version-dev.aab"
            ;;
        prod)
            aab_source=$(get_build_path "android_aab_prod")
            aab_target="build/app/outputs/bundle/prodRelease/$appname-$version.aab"
            ;;
        *)
            print_warning "No specific flavor handling for app bundle"
            return
            ;;
    esac
    
    if [ -f "$aab_source" ]; then
        mv "$aab_source" "$aab_target"
        add_build_artifact "$aab_target" "AAB"
        print_status "App Bundle renamed to: $aab_target"
        
        if [ "$OUTPUT_DIR" != "build" ]; then
            cp "$aab_target" "$OUTPUT_DIR/"
            local output_aab="$OUTPUT_DIR/$(basename "$aab_target")"
            add_build_artifact "$output_aab" "AAB"
            print_status "App Bundle copied to: $OUTPUT_DIR/"
        fi
    fi
    
    end_group "Building Android App Bundle"
}

build_ipa() {
    print_status "Building iOS IPA..."
    flutter build ios "${FLUTTER_ARGS[@]}"
    
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
    
    if [ "$OUTPUT_DIR" != "build" ]; then
        cp "build/$ipa_name" "$OUTPUT_DIR/"
        add_build_artifact "$OUTPUT_DIR/$ipa_name" "IPA"
        print_status "IPA copied to: $OUTPUT_DIR/$ipa_name"
    else
        add_build_artifact "build/$ipa_name" "IPA"
        print_status "IPA created: build/$ipa_name"
    fi
}

build_dmg() {
    print_status "Building macOS DMG..."
    
    if ! command_exists create-dmg; then
        exit_with_error "create-dmg not found. Install with: brew install create-dmg"
    fi
    
    flutter build macos "${FLUTTER_ARGS[@]}"
    
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
    
    if [ "$OUTPUT_DIR" != "build" ]; then
        cp "build/$dmg_name" "$OUTPUT_DIR/"
        add_build_artifact "$OUTPUT_DIR/$dmg_name" "DMG"
        print_status "DMG copied to: $OUTPUT_DIR/$dmg_name"
    else
        add_build_artifact "build/$dmg_name" "DMG"
        print_status "DMG created: build/$dmg_name"
    fi
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
    esac
}

#==============================================================================
# MAIN EXECUTION LOGIC
#==============================================================================

main() {
    BUILD_START_TIME=$(date +%s)

    init_variables
    get_app_info

    warn_pubspec_backup

    parse_arguments "$@"

    validate_format "$FORMAT"
    validate_build_modes
    validate_flavor_value
    set_target_file_and_env
    validate_output_dir
    validate_prod_environment

    print_status "Building $appname version $version as $FORMAT ($BUILD_MODE)"
    print_debug "Target file: $TARGET_FILE"
    print_debug "Flavor: ${FLAVOR:-none}"
    print_debug "FOSS build: $FOSS_BUILD"
    print_debug "CI mode: $IS_CI"

    if [ "$DRY_RUN" = true ]; then
        local flutter_platform=$(get_platform_config "$FORMAT")
        echo "DRY RUN - Would execute:"
        echo "flutter build $flutter_platform ${FLUTTER_ARGS[*]}"
        exit 0
    fi

    trap 'restore_pubspec; exit' INT TERM EXIT

    mkdir -p "$OUTPUT_DIR"
    create_pubspec_backup

    if [ "$FOSS_BUILD" = true ]; then
        if ! prepare_foss_build; then
            exit_with_error "FOSS build preparation failed"
        fi
    fi

    execute_build

    restore_pubspec

    show_build_summary

    trap - INT TERM EXIT
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