# dmg.sh
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
    flutter build macos --release --flavor dev --dart-define-from-file env/dev.json -t lib/main.dart \
    && cp -r build/macos/Build/Products/Release-dev/Boorusama-DEV.app build/Boorusama-DEV.app \
    && create-dmg --hdiutil-quiet build/${appname}-${version}-dev.dmg build/Boorusama-DEV.app \
    && rm -rf build/Boorusama-DEV.app
    ;;
  prod)
    flutter build macos --release --flavor prod --dart-define-from-file env/prod.json -t lib/main.dart \
    && cp -r build/macos/Build/Products/Release-prod/Boorusama.app build/Boorusama.app \
    && create-dmg --hdiutil-quiet build/${appname}-${version}.dmg build/Boorusama.app \
    && rm -rf build/Boorusama.app
    ;;
  *)
    echo "Invalid flavor provided"
    exit 1
    ;;
esac