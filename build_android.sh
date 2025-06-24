#!/bin/bash
# filepath: /Users/khoa.nguyen/Work/playground/my_app/build_android.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

# Parse command line arguments
FOSS_BUILD=false
BUILD_TYPE="release"

while [[ $# -gt 0 ]]; do
    case $1 in
        --foss)
            FOSS_BUILD=true
            shift
            ;;
        --debug)
            BUILD_TYPE="debug"
            shift
            ;;
        --release)
            BUILD_TYPE="release"
            shift
            ;;
        --profile)
            BUILD_TYPE="profile"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --foss      Build FOSS version without RevenueCat"
            echo "  --debug     Build debug version (default: release)"
            echo "  --release   Build release version"
            echo "  --profile   Build profile version"
            echo "  -h, --help  Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Backup original pubspec.yaml
BACKUP_FILE="pubspec.yaml.backup"
cp pubspec.yaml "$BACKUP_FILE"
print_status "Created backup of pubspec.yaml"

# Function to restore pubspec.yaml
restore_pubspec() {
    if [ -f "$BACKUP_FILE" ]; then
        mv "$BACKUP_FILE" pubspec.yaml
        print_status "Restored original pubspec.yaml"
    fi
}

# Trap to ensure cleanup on exit
trap 'restore_pubspec; exit' INT TERM EXIT

if [ "$FOSS_BUILD" = true ]; then
    print_status "Building FOSS version..."
    
    # Remove RevenueCat dependency from pubspec.yaml
    print_status "Removing RevenueCat dependency..."
    sed -i.tmp '/purchases_flutter:/d' pubspec.yaml
    rm pubspec.yaml.tmp
    
    # Get dependencies without RevenueCat
    print_status "Getting dependencies..."
    flutter pub get
    
    # Build with main2.dart as entry point
    print_status "Building Android $BUILD_TYPE APK (FOSS)..."
    flutter build apk --$BUILD_TYPE -t lib/main2.dart
    
    # Rename the output file to indicate it's a FOSS build
    APK_PATH="build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
    FOSS_APK_PATH="build/app/outputs/flutter-apk/app-$BUILD_TYPE-foss.apk"
    
    if [ -f "$APK_PATH" ]; then
        mv "$APK_PATH" "$FOSS_APK_PATH"
        print_status "FOSS APK created: $FOSS_APK_PATH"
    fi
    
else
    print_status "Building standard version..."
    
    # Standard build with main.dart
    print_status "Getting dependencies..."
    flutter pub get
    
    print_status "Building Android $BUILD_TYPE APK..."
    flutter build apk --$BUILD_TYPE -t lib/main.dart
    
    APK_PATH="build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
    if [ -f "$APK_PATH" ]; then
        print_status "Standard APK created: $APK_PATH"
    fi
fi

# Restore original pubspec.yaml and get dependencies
restore_pubspec
print_status "Getting original dependencies..."
flutter pub get

print_status "Build completed successfully!"

# Disable trap since we're cleaning up manually
trap - INT TERM EXIT
