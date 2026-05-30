import 'dart:io';

final class FossBackups {
  const FossBackups._();

  static List<File> find(Directory root) {
    return root.listSync().whereType<File>().where((file) {
      final name = file.uri.pathSegments.last;
      return name.startsWith('pubspec.yaml.backup.') ||
          name.startsWith('pubspec.lock.backup.');
    }).toList();
  }

  static String displayName(File file) => file.uri.pathSegments.last;
}
