#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'dev', or 'prod'."
  exit 1
fi

case $1 in
  dev)
    flutterfire config \
      --project=boorusama-dev \
      --out=lib/core/firebase/firebase_options_dev.dart \
      --ios-bundle-id=com.degenk.boorusama.dev \
      --ios-out=ios/flavors/dev/GoogleService-Info.plist \
      --macos-bundle-id=com.degenk.boorusama.dev \
      --macos-out=macos/flavors/dev/GoogleService-Info.plist \
      --android-package-name=com.degenk.boorusama.dev \
      --android-out=android/app/src/dev/google-services.json
    ;;
  prod)
    flutterfire config \
      --project=boorusama-40f9d \
      --out=lib/core/firebase/firebase_options_prod.dart \
      --ios-bundle-id=com.degenk.boorusama \
      --ios-out=ios/flavors/prod/GoogleService-Info.plist \
      --macos-bundle-id=com.degenk.boorusama \
      --macos-out=macos/flavors/prod/GoogleService-Info.plist \
      --android-package-name=com.degenk.boorusama \
      --android-out=android/app/src/prod/google-services.json
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'dev' or 'prod'."
    exit 1
    ;;
esac