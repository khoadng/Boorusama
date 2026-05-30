import 'dart:io';

final class Changelog {
  const Changelog(this.file);

  final File file;

  String sectionFor(String version) {
    if (!file.existsSync()) {
      throw StateError('CHANGELOG.md not found: ${file.path}');
    }

    final lines = file.readAsLinesSync();
    final heading = '# $version';
    final buffer = StringBuffer();
    var found = false;

    for (final line in lines) {
      if (line.trim() == heading) {
        found = true;
        continue;
      }

      if (found && line.startsWith('# ')) break;
      if (found) buffer.writeln(line);
    }

    if (!found) {
      throw StateError('CHANGELOG.md does not contain a # $version section.');
    }

    final section = buffer.toString().trim();
    if (section.isEmpty) {
      throw StateError('CHANGELOG.md section # $version is empty.');
    }

    return section;
  }
}
