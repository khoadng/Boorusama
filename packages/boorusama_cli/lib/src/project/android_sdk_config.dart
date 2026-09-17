import 'dart:io';

final class AndroidSdkConfig {
  const AndroidSdkConfig({
    required this.compileSdk,
    required this.targetSdk,
    required this.minSdk,
    required this.buildTools,
    required this.ndk,
  });

  factory AndroidSdkConfig.read(File file) {
    if (!file.existsSync()) {
      throw StateError('Android properties file not found: ${file.path}');
    }

    final properties = <String, String>{};
    for (final rawLine in file.readAsLinesSync()) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final separator = line.indexOf('=');
      if (separator < 1) continue;
      properties[line.substring(0, separator).trim()] = line
          .substring(separator + 1)
          .trim();
    }

    String requireProperty(String key) {
      final value = properties[key];
      if (value == null || value.isEmpty) {
        throw FormatException('Missing Android property $key in ${file.path}');
      }
      return value;
    }

    int requireInt(String key) {
      final value = requireProperty(key);
      final parsed = int.tryParse(value);
      if (parsed == null) {
        throw FormatException(
          'Android property $key must be an integer in ${file.path}: $value',
        );
      }
      return parsed;
    }

    return AndroidSdkConfig(
      compileSdk: requireInt('boorusama.android.compileSdk'),
      targetSdk: requireInt('boorusama.android.targetSdk'),
      minSdk: requireInt('boorusama.android.minSdk'),
      buildTools: requireProperty('boorusama.android.buildTools'),
      ndk: requireProperty('boorusama.android.ndk'),
    );
  }

  final int compileSdk;
  final int targetSdk;
  final int minSdk;
  final String buildTools;
  final String ndk;

  List<String> get sdkManagerPackages => [
    'platforms;android-$compileSdk',
    'build-tools;$buildTools',
    'ndk;$ndk',
  ];
}
