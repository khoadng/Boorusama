#!/bin/bash

version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)

flutter build apk --release -t lib/main.dart \
&& mkdir -p build/APK \
&& cp build/app/outputs/flutter-apk/app-release.apk build/APK/boorusama_${version}.apk \
&& echo "APK generated at: build/APK/boorusama_${version}.apk"
