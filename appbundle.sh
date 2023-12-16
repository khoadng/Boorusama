#!/bin/bash

# Check if the flavor argument is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <flavor>"
  exit 1
fi

# Get the flavor argument
FLAVOR=$1

version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)
appname=$(head -n 1 pubspec.yaml | cut -d ' ' -f 2)

echo "Building $appname version $version for $FLAVOR"

# Run the Flutter command based on the flavor
case $FLAVOR in
  dev)
    flutter build appbundle --release --flavor dev --dart-define-from-file env/dev.json
    mv "build/app/outputs/bundle/devRelease/app-dev-release.aab" "build/app/outputs/bundle/devRelease/$appname-$version-dev.aab"
    ;;
  prod)
    flutter build appbundle --release --flavor prod --dart-define-from-file env/prod.json
    mv "build/app/outputs/bundle/prodRelease/app-prod-release.aab" "build/app/outputs/bundle/prodRelease/$appname-$version.aab"
    ;;
  *)
    echo "Invalid flavor provided"
    exit 1
    ;;
esac
