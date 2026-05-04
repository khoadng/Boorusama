import 'dart:io';

import 'package:test/test.dart';

import 'package:boorusama_cli/src/project/pubspec.dart';
import 'package:boorusama_cli/src/release/changelog.dart';
import 'package:boorusama_cli/src/release/release_version.dart';

void main() {
  group('ReleaseVersion', () {
    test('uses pubspec version name as git tag', () {
      final version = ReleaseVersion.fromPubspec(
        const PubspecInfo(
          name: 'boorusama',
          version: '4.4.0+177',
          versionName: '4.4.0',
          buildNumber: '177',
        ),
      );

      expect(version.full, '4.4.0+177');
      expect(version.name, '4.4.0');
      expect(version.buildNumber, '177');
      expect(version.tag, 'v4.4.0');
    });

    test('rejects invalid pubspec version', () {
      expect(
        () => ReleaseVersion.fromPubspec(
          const PubspecInfo(
            name: 'boorusama',
            version: 'version 4',
            versionName: 'version 4',
            buildNumber: null,
          ),
        ),
        throwsStateError,
      );
    });
  });

  group('Changelog', () {
    test('extracts a version section', () async {
      final dir = await Directory.systemTemp.createTemp('boorusama_cli_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/CHANGELOG.md')
        ..writeAsStringSync('''
# 4.4.0
- One
- Two

# 4.3.0
- Old
''');

      expect(Changelog(file).sectionFor('4.4.0'), '- One\n- Two');
    });

    test('fails when version section is missing', () async {
      final dir = await Directory.systemTemp.createTemp('boorusama_cli_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/CHANGELOG.md')
        ..writeAsStringSync('# 4.3.0\n- Old\n');

      expect(() => Changelog(file).sectionFor('4.4.0'), throwsStateError);
    });
  });
}
