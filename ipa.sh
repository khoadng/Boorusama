version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)

flutter build ios --release --no-codesign -t lib/main.dart \
&& mkdir build/Payload \
&& cp -r build/ios/Release-iphoneos/Runner.app/ build/Payload/Runner.app/ \
&& cd build \
&& zip -ro boorusama_${version}.ipa Payload \
&& rm -rf Payload