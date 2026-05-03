import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('booru_i18n CLI', () {
    late Directory tempDir;
    late Directory i18nDir;
    late Directory translationsDir;
    late Directory repoFixtureDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('i18n_cli_process_test_');
      i18nDir = Directory(p.join(tempDir.path, 'i18n'))
        ..createSync(recursive: true);
      translationsDir = Directory(p.join(i18nDir.path, 'translations'))
        ..createSync(recursive: true);

      File(p.join(i18nDir.path, 'slang.yaml')).writeAsStringSync('''
base_locale: en-US
input_directory: translations
''');

      File(p.join(translationsDir.path, 'en-US.json')).writeAsStringSync('''
{
  "generic": {
    "done": "Done"
  }
}
''');

      File(p.join(translationsDir.path, 'vi-VN.json')).writeAsStringSync('''
{
  "generic": {
    "done": "Xong"
  }
}
''');

      repoFixtureDir = Directory(
        p.join(_repoRoot(), 'packages', 'i18n_cli', 'test', '.tmp_apply'),
      )..createSync(recursive: true);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
      if (repoFixtureDir.existsSync()) {
        repoFixtureDir.deleteSync(recursive: true);
      }
    });

    test('reads a key as JSON', () async {
      final result = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        '--json',
        'get',
        'generic.done',
      ]);

      expect(result.exitCode, 0);
      final output = jsonDecode(result.stdout as String);
      expect(output, containsPair('ok', true));
      expect(output, containsPair('value', 'Done'));
    });

    test('dry-run diff reports patch without writing', () async {
      final result = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        'add',
        'generic.cancel',
        '-t',
        'en-US=Cancel',
        '--dry-run',
        '--diff',
      ]);

      expect(result.exitCode, 0);
      expect(result.stdout, contains('--- '));
      expect(result.stdout, contains('+    "cancel": "Cancel"'));
      expect(
        File(p.join(translationsDir.path, 'en-US.json')).readAsStringSync(),
        isNot(contains('cancel')),
      );
    });

    test('prints tree', () async {
      final result = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        'tree',
        'generic',
        '--depth',
        '1',
      ]);

      expect(result.exitCode, 0);
      expect(result.stdout, 'generic\n  done\n');
    });

    test('rejects diff without dry-run', () async {
      final result = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        'add',
        'generic.cancel',
        '-t',
        'en-US=Cancel',
        '--diff',
      ]);

      expect(result.exitCode, 2);
      expect(result.stderr, contains('--diff requires --dry-run'));
    });

    test('batch add reports preflight details', () async {
      final result = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        'add-batch',
        'generic',
        'done=Done',
        'cancel=Done',
        '--dry-run',
        '--diff',
      ]);

      expect(result.exitCode, 0);
      expect(result.stdout, contains('new keys:'));
      expect(result.stdout, contains('generic.cancel'));
      expect(result.stdout, contains('already exists:'));
      expect(result.stdout, contains('generic.done = Done'));
      expect(result.stdout, contains('same value elsewhere:'));
      expect(result.stdout, contains('generic.cancel: generic.done = Done'));
      expect(result.stdout, contains('+    "cancel": "Done"'));
      expect(
        File(p.join(translationsDir.path, 'en-US.json')).readAsStringSync(),
        isNot(contains('cancel')),
      );
    });

    test('applies manifest with dry-run diff', () async {
      final sourceFile = File(p.join(repoFixtureDir.path, 'copy_fixture.dart'))
        ..writeAsStringSync("final title = 'Copy'.hc;\n");
      final manifest = File(p.join(repoFixtureDir.path, 'manifest.json'))
        ..writeAsStringSync(
          jsonEncode({
            'locale': 'en-US',
            'add': {
              'generic.copy': 'Copy',
            },
            'replace': [
              {
                'file': p.relative(sourceFile.path, from: _repoRoot()),
                'from': "'Copy'.hc",
                'to': 'context.t.generic.copy',
                'count': 1,
              },
            ],
          }),
        );

      final result = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        'apply',
        manifest.path,
        '--dry-run',
        '--diff',
      ]);

      expect(result.exitCode, 0);
      expect(result.stdout, contains('new keys:'));
      expect(result.stdout, contains('generic.copy'));
      expect(result.stdout, contains('replacements:'));
      expect(result.stdout, contains('copy_fixture.dart: 1 replacement(s)'));
      expect(result.stdout, contains('+    "copy": "Copy"'));
      expect(result.stdout, contains('+final title = context.t.generic.copy;'));
      expect(sourceFile.readAsStringSync(), "final title = 'Copy'.hc;\n");
      expect(
        File(p.join(translationsDir.path, 'en-US.json')).readAsStringSync(),
        isNot(contains('"copy": "Copy"')),
      );
    });

    test('normalizes tolerant manifest input', () async {
      final sourceFile = File(p.join(repoFixtureDir.path, 'copy_fixture.dart'))
        ..writeAsStringSync(
          "final title = 'Copy'.hc;\nfinal error = 'Bad'.hc;\n",
        );
      final relativeSourceFile = p.relative(sourceFile.path, from: _repoRoot());
      final manifest = File(p.join(repoFixtureDir.path, 'messy_manifest.md'))
        ..writeAsStringSync('''
Here is the manifest:

```json
{
  "locale": "en-US",
  "parent": "post.action",
  "keys": [
    {"name": "copy", "text": "Copy"},
    {"name": "failed", "text": "Failed: {e}"},
  ],
  "replacements": [
    {
      "path": "$relativeSourceFile",
      "old": "'Copy'.hc",
      "new": "context.t.post.action.copy",
    },
    {
      "path": "$relativeSourceFile",
      "old": "'Bad'.hc",
      "new": "context.t.post.action.failed(e: e)",
    },
  ],
}
```
''');

      final normalizeResult = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        'normalize-manifest',
        manifest.path,
      ]);

      expect(normalizeResult.exitCode, 0);
      final normalized = jsonDecode(normalizeResult.stdout as String);
      expect(normalized['add']['post.action.copy'], 'Copy');
      expect(normalized['add']['post.action.failed'], r'Failed: $e');
      expect(normalizeResult.stderr, contains('normalized 2 relative key(s)'));
      expect(normalizeResult.stderr, contains('normalized placeholder'));
      expect(normalizeResult.stderr, isNot(contains(relativeSourceFile)));

      final applyResult = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        'apply',
        manifest.path,
        '--dry-run',
        '--diff',
      ]);

      expect(applyResult.exitCode, 0);
      expect(
        applyResult.stderr,
        contains('inferred counts for 2 replacement(s)'),
      );
      expect(
        applyResult.stdout,
        contains('copy_fixture.dart: 2 replacement(s)'),
      );
      expect(applyResult.stdout, contains('+      "copy": "Copy",'));
      expect(applyResult.stdout, contains(r'+      "failed": "Failed: $e"'));
      expect(
        applyResult.stdout,
        contains('+final title = context.t.post.action.copy;'),
      );
      expect(
        applyResult.stdout,
        contains('+final error = context.t.post.action.failed(e: e);'),
      );
      expect(sourceFile.readAsStringSync(), contains("'Copy'.hc"));
    });

    test('rejects manifest replacement count mismatch', () async {
      final sourceFile = File(p.join(repoFixtureDir.path, 'copy_fixture.dart'))
        ..writeAsStringSync("final title = 'Copy'.hc;\n");
      final manifest = File(p.join(repoFixtureDir.path, 'manifest.json'))
        ..writeAsStringSync(
          jsonEncode({
            'replace': [
              {
                'file': p.relative(sourceFile.path, from: _repoRoot()),
                'from': "'Copy'.hc",
                'to': 'context.t.generic.copy',
                'count': 2,
              },
            ],
          }),
        );

      final result = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        'apply',
        manifest.path,
        '--dry-run',
      ]);

      expect(result.exitCode, 1);
      expect(result.stderr, contains('Replacement count mismatch'));
      expect(sourceFile.readAsStringSync(), "final title = 'Copy'.hc;\n");
    });

    test('prints manifest template', () async {
      final result = await _runCli(['manifest-template']);

      expect(result.exitCode, 0);
      final output = jsonDecode(result.stdout as String);
      expect(output, containsPair('locale', 'en-US'));
      expect(output, containsPair('add', isA<Map<String, dynamic>>()));
      expect(output, containsPair('replace', isA<List<dynamic>>()));
    });

    test('writes an add command', () async {
      final result = await _runCli([
        '--i18n-dir',
        i18nDir.path,
        'add',
        'generic.cancel',
        '-t',
        'en-US=Cancel',
      ]);

      expect(result.exitCode, 0);
      expect(
        File(p.join(translationsDir.path, 'en-US.json')).readAsStringSync(),
        contains('"cancel": "Cancel"'),
      );
    });
  });
}

Future<ProcessResult> _runCli(List<String> arguments) {
  return Process.run(
    Platform.resolvedExecutable,
    ['run', 'i18n_cli:booru_i18n', ...arguments],
    workingDirectory: _repoRoot(),
  );
}

String _repoRoot() {
  var directory = Directory.current;

  while (true) {
    final pubspec = File(p.join(directory.path, 'pubspec.yaml'));
    final packageDirectory = Directory(p.join(directory.path, 'packages'));

    if (pubspec.existsSync() && packageDirectory.existsSync()) {
      return directory.path;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      throw StateError('Could not find repository root.');
    }

    directory = parent;
  }
}
