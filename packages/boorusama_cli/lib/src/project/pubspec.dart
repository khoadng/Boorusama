import 'dart:io';

import 'package:yaml/yaml.dart';

final class PubspecInfo {
  const PubspecInfo({
    required this.name,
    required this.version,
    required this.versionName,
    required this.buildNumber,
  });

  final String name;
  final String version;
  final String versionName;
  final String? buildNumber;

  static PubspecInfo read(File file) {
    final map = loadYaml(file.readAsStringSync()) as YamlMap;
    final name = map['name'] as String;
    final version = map['version'] as String;
    final parts = version.split('+');
    return PubspecInfo(
      name: name,
      version: version,
      versionName: parts.first,
      buildNumber: parts.length > 1 ? parts[1] : null,
    );
  }
}
