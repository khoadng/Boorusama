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

    final releaseArtifacts = <_GithubReleaseArtifact>[];
    for (final file in artifact.files) {
      final releaseFile = await _copyReleaseArtifact(
        source: file,
        fileName: githubReleaseArtifactName(
          target: target,
          app: project.pubspec.name,
          fullVersion: version.full,
          sourceName: p.basename(file.path),
        ),
      );
      releaseArtifacts.add(
        _GithubReleaseArtifact(
          type: artifact.type,
          file: releaseFile,
        ),
      );
    }

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
        for (final artifact in releaseArtifacts)
          <String, Object?>{
            'type': artifact.type,
            'fileName': p.basename(artifact.file.path),
            'relativePath': p.basename(artifact.file.path),
            'sha256': await sha256Of(artifact.file),
            'size': artifact.file.lengthSync(),
          },
      ],
    };

    final receiptFile = File('${receiptDir.path}/$target.json');
    receiptFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(receipt),
    );
    return receiptFile;
  }

  Future<File> _copyReleaseArtifact({
    required File source,
    required String fileName,
  }) async {
    final target = File('${outputDir.path}/$fileName');
    if (source.absolute.path == target.absolute.path) return source;

    if (target.existsSync()) target.deleteSync();
    return source.copy(target.path);
  }

  static Future<String> sha256Of(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }
}

String githubReleaseArtifactName({
  required String target,
  required String app,
  required String fullVersion,
  required String sourceName,
}) {
  final prefix = '$app-$fullVersion';
  return switch (target) {
    'apk' => '$prefix-android-${_androidArchitecture(sourceName)}.apk',
    'ipa' => '$prefix-ios.ipa',
    'dmg' => '$prefix-macos.dmg',
    'windows-zip' => '$prefix-windows-x64.zip',
    'linux-tar.gz' => '$prefix-linux-${_linuxArchitecture(sourceName)}.tar.gz',
    'appimage' => '$prefix-linux-${_linuxArchitecture(sourceName)}.AppImage',
    _ => sourceName,
  };
}

String _androidArchitecture(String sourceName) {
  if (sourceName.endsWith('-arm64-v8a.apk')) return 'arm64';
  if (sourceName.endsWith('-armeabi-v7a.apk')) return 'armv7';
  if (sourceName.endsWith('-x86_64.apk')) return 'x64';
  return 'universal';
}

String _linuxArchitecture(String sourceName) {
  final match = RegExp(
    r'-linux-([^-]+)\.(?:tar\.gz|AppImage)$',
  ).firstMatch(sourceName);
  return match?.group(1) ?? 'x64';
}

final class _GithubReleaseArtifact {
  const _GithubReleaseArtifact({
    required this.type,
    required this.file,
  });

  final String type;
  final File file;
}
