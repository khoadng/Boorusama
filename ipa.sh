#!/bin/bash

# Check if the flavor argument is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <flavor>"
  exit 1
fi

FLAVOR=$1
version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)
appname=$(head -n 1 pubspec.yaml | cut -d ' ' -f 2)

echo "Building $appname version $version for $FLAVOR"

case $FLAVOR in
  dev)
    flutter build ios --release --no-codesign --flavor dev --dart-define-from-file env/dev.json -t lib/main.dart \
    && mkdir build/Payload \
    && cp -r build/ios/Release-iphoneos/Runner.app/ build/Payload/Runner.app/ \
    && cd build \
    && zip -ro ${appname}_${version}-dev.ipa Payload \
    && rm -rf Payload
    ;;
  prod)
    flutter build ios --release --no-codesign --flavor prod --dart-define-from-file env/prod.json -t lib/main.dart \
    && mkdir build/Payload \
    && cp -r build/ios/Release-iphoneos/Runner.app/ build/Payload/Runner.app/ \
    && cd build \
    && zip -ro ${appname}_${version}.ipa Payload \
    && rm -rf Payload
    ;;
  *)
    echo "Invalid flavor provided"
    exit 1
    ;;
esac