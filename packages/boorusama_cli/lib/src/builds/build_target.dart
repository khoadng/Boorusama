enum BuildTarget {
  apk,
  aab,
  ipa,
  dmg,
  windows,
  linux,
  appimage,
  flatpak,
  web
  ;

  static BuildTarget? parse(String value) {
    for (final target in values) {
      if (target.name == value) return target;
    }
    return null;
  }

  String get flutterTarget => switch (this) {
    BuildTarget.apk => 'apk',
    BuildTarget.aab => 'appbundle',
    BuildTarget.ipa => 'ios',
    BuildTarget.dmg => 'macos',
    BuildTarget.windows => 'windows',
    BuildTarget.linux || BuildTarget.appimage || BuildTarget.flatpak => 'linux',
    BuildTarget.web => 'web',
  };

  bool get requiresFlavor => switch (this) {
    BuildTarget.apk ||
    BuildTarget.aab ||
    BuildTarget.ipa ||
    BuildTarget.dmg => true,
    BuildTarget.windows ||
    BuildTarget.linux ||
    BuildTarget.appimage ||
    BuildTarget.flatpak ||
    BuildTarget.web => false,
  };
}
