import 'dart:convert';
import 'dart:io';

import 'package:boorusama_cli/src/package/artifact.dart';
import 'package:boorusama_cli/src/project/env.dart';
import 'package:boorusama_cli/src/project/git.dart';
import 'package:boorusama_cli/src/project/project.dart';
import 'package:boorusama_cli/src/project/pubspec.dart';
import 'package:boorusama_cli/src/release/github/receipt.dart';
import 'package:boorusama_cli/src/release/version/release_version.dart';
import 'package:test/test.dart';

void main() {
  group('githubReleaseArtifactName', () {
    const app = 'boorusama';
    const version = '4.5.0+184';

    test('uses readable Android architecture names', () {
      expect(
        githubReleaseArtifactName(
          target: 'apk',
          app: app,
          fullVersion: version,
          sourceName: 'boorusama-4.5.0+184-prod-foss-arm64-v8a.apk',
        ),
        'boorusama-4.5.0+184-android-arm64.apk',
      );
      expect(
        githubReleaseArtifactName(
          target: 'apk',
          app: app,
          fullVersion: version,
          sourceName: 'boorusama-4.5.0+184-prod-foss-armeabi-v7a.apk',
        ),
        'boorusama-4.5.0+184-android-armv7.apk',
      );
      expect(
        githubReleaseArtifactName(
          target: 'apk',
          app: app,
          fullVersion: version,
          sourceName: 'boorusama-4.5.0+184-prod-foss-x86_64.apk',
        ),
        'boorusama-4.5.0+184-android-x64.apk',
      );
    });

    test('uses platform names for desktop and iOS assets', () {
      expect(
        githubReleaseArtifactName(
          target: 'dmg',
          app: app,
          fullVersion: version,
          sourceName: 'boorusama-4.5.0+184.dmg',
        ),
        'boorusama-4.5.0+184-macos.dmg',
      );
      expect(
        githubReleaseArtifactName(
          target: 'windows-zip',
          app: app,
          fullVersion: version,
          sourceName: 'boorusama-4.5.0+184.zip',
        ),
        'boorusama-4.5.0+184-windows-x64.zip',
      );
      expect(
        githubReleaseArtifactName(
          target: 'ipa',
          app: app,
          fullVersion: version,
          sourceName: 'boorusama_4.5.0+184.ipa',
        ),
        'boorusama-4.5.0+184-ios.ipa',
      );
    });

    test('keeps Linux architecture names', () {
      expect(
        githubReleaseArtifactName(
          target: 'linux-tar.gz',
          app: app,
          fullVersion: version,
          sourceName: 'boorusama-4.5.0+184-foss-linux-x64.tar.gz',
        ),
        'boorusama-4.5.0+184-linux-x64.tar.gz',
      );
      expect(
        githubReleaseArtifactName(
          target: 'appimage',
          app: app,
          fullVersion: version,
          sourceName: 'boorusama-4.5.0+184-foss-linux-x64.AppImage',
        ),
        'boorusama-4.5.0+184-linux-x64.AppImage',
      );
    });
  });

  test('receipt points at GitHub-facing artifact copy', () async {
    final temp = await Directory.systemTemp.createTemp('github_receipt_test_');
    addTearDown(() => temp.deleteSync(recursive: true));

    final source = File('${temp.path}/boorusama-4.5.0+184.zip')
      ..writeAsStringSync('windows zip');
    final receipt = await GithubReceipt(outputDir: temp).write(
      target: 'windows-zip',
      project: _project(temp),
      version: const ReleaseVersion(
        full: '4.5.0+184',
        name: '4.5.0',
        buildNumber: '184',
      ),
      artifact: Artifact.single(type: 'Windows ZIP', file: source),
    );

    final releaseFile = File(
      '${temp.path}/boorusama-4.5.0+184-windows-x64.zip',
    );
    expect(releaseFile.existsSync(), isTrue);
    expect(releaseFile.readAsStringSync(), 'windows zip');

    final decoded =
        jsonDecode(receipt.readAsStringSync()) as Map<String, Object?>;
    final artifacts = decoded['artifacts'] as List<Object?>;
    final artifact = artifacts.single as Map<String, Object?>;
    expect(
      artifact['fileName'],
      'boorusama-4.5.0+184-windows-x64.zip',
    );
  });
}

Project _project(Directory root) {
  return Project(
    root: root,
    pubspec: const PubspecInfo(
      name: 'boorusama',
      version: '4.5.0+184',
      versionName: '4.5.0',
      buildNumber: '184',
    ),
    env: const Env({}, includePlatform: false),
    git: const GitInfo(commit: 'abc123', branch: '4.5.0'),
  );
}
