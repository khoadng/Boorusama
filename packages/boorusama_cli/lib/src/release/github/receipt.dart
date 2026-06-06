import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../../package/artifact.dart';
import '../../project/project.dart';
import '../version/release_version.dart';

final class GithubReceipt {
  const GithubReceipt({required this.outputDir});

  final Directory outputDir;

  Future<File> write({
    required String target,
    required Project project,
    required ReleaseVersion version,
    required Artifact artifact,
  }) async {
    for (final file in artifact.files) {
      if (!file.existsSync()) {
        throw StateError(
          'Expected artifact does not exist: ${file.path}',
        );
      }
    }

    final receiptDir = Directory('${outputDir.path}/release/github');
    if (!receiptDir.existsSync()) receiptDir.createSync(recursive: true);

    final receipt = <String, Object?>{
      'kind': 'github-release-artifact',
      'target': target,
      'app': project.pubspec.name,
      'version': version.name,
      'buildNumber': version.buildNumber,
      'fullVersion': version.full,
      'tag': version.tag,
      'commit': project.git.commit,
      'artifacts': [
        for (final file in artifact.files)
          <String, Object?>{
            'type': artifact.type,
            'fileName': p.basename(file.path),
            'relativePath': p.basename(file.path),
            'sha256': await sha256Of(file),
            'size': file.lengthSync(),
          },
      ],
    };

    final receiptFile = File('${receiptDir.path}/$target.json');
    receiptFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(receipt),
    );
    return receiptFile;
  }

  static Future<String> sha256Of(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }
}
