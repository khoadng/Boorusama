version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)

flutter build macos --release -t lib/main.dart \
&& cp -r build/macos/Build/Products/Release/boorusama.app build/boorusama.app \
&& create-dmg --hdiutil-quiet build/Boorusama-${version}.dmg build/boorusama.app \
&& rm -rf build/boorusama.app