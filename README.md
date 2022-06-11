# Boorusama

## Run the generator

Use build_runner to generate boilerplate files

```bash
#!/bin/bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Run upgrade command

```bash
#!/bin/bash
dart fix --apply

flutter pub upgrade

flutter pub outdated
```

## Upgrading pre 1.12 Android projects

> Read more [here](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects)

## "flutter pub get" A required privilege is not held by the client

> Read more [here](https://stackoverflow.com/questions/69427548/flutter-pub-get-a-required-privilege-is-not-held-by-the-client)

## Open android emulator

```bash
#!/bin/bash
# using flutter sdk
# https://docs.flutter.dev/reference/flutter-cli#flutter-commands
flutter emulators
flutter emulators --launch @name-of-your-emulator
# ex:
flutter emulators --launch Pixel_5_API_31
```

```bash
#!/bin/bash
# using android sdk
# https://developer.android.com/studio/run/emulator-commandline
emulator -list-avds
emulator -avd @name-of-your-emulator
# ex:
emulator -avd Pixel_5_API_31
```

## Stop android emulator

```bash
#!/bin/bash
# List of devices attached
adb devices
# stop emulator
adb kill-server
# or
adb -s @name-of-your-emulator emu kill
# ex:
adb -s emulator-5554 emu kill
```

## Run application for development

```bash
#!/bin/bash
flutter run
# with some option
flutter run --enable-software-rendering --skia-deterministic-rendering --pub --build
```

## Android studio cannot resolve symbol 'GradleException'

Read more [here](https://stackoverflow.com/questions/55575122/android-studio-cannot-resolve-symbol-gradleexception)

## Build android

```bash
#!/bin/bash
# release
flutter build appbundle --release
flutter build apk --split-per-abi --release
flutter build assembleRelease
# debug
flutter build apk --split-per-abi --debug
```

## Fix app crashes on certain devices on Android 6.0

> Read more [here](https://docs.flutter.dev/deployment/android#building-the-app-for-release)
