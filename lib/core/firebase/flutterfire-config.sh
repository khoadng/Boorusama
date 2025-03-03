#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'dev', or 'prod'."
  exit 1
fi

case $1 in
  dev)
    if [[ -z $FIREBASE_PROJECT ]]; then
      FIREBASE_PROJECT=boorusama-dev
    fi
    APP_ID=com.degenk.boorusama.dev
    FLAVOR=dev
    ;;
  prod)
    if [[ -z $FIREBASE_PROJECT ]]; then
      FIREBASE_PROJECT=boorusama-40f9d
    fi
    APP_ID=com.degenk.boorusama
    FLAVOR=prod
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'dev' or 'prod'."
    exit 1
    ;;
esac

IOS_ARGS="--ios-bundle-id=${APP_ID} --ios-build-config=Release-${FLAVOR} --ios-out=ios/flavors/${FLAVOR}/GoogleService-Info.plist"
MACOS_ARGS="--macos-bundle-id=${APP_ID} --macos-out=macos/flavors/${FLAVOR}/GoogleService-Info.plist"
ANDROID_ARGS="--android-package-name=${APP_ID} --android-out=android/app/src/${FLAVOR}/google-services.json"

ARGS=""

# if CI_PLATFORMS is set, use it to determine the platform
# example: CI_PLATFORMS=ios,android
if [[ -n $CI_PLATFORMS ]]; then
  ARGS="--token=$FIREBASE_TOKEN --yes --platforms=$CI_PLATFORMS"
  for platform in $(echo $CI_PLATFORMS | tr "," "\n"); do
    case $platform in
      ios)
        ARGS="$ARGS $IOS_ARGS"
        ;;
      macos)
        ARGS="$ARGS $MACOS_ARGS"
        ;;
      android)
        ARGS="$ARGS $ANDROID_ARGS"
        ;;
      *)
        echo "Error: Invalid platform specified. Use 'ios', 'macos', or 'android'."
        exit 1
        ;;
    esac
  done
else
  ARGS="$IOS_ARGS $MACOS_ARGS $ANDROID_ARGS"
fi


flutterfire config \
  --project=${FIREBASE_PROJECT} \
  --out=lib/core/firebase/firebase_options_${FLAVOR}.dart \
  $ARGS
