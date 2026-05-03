import 'dart:io';

import 'package:i18n_cli/src/config.dart';
import 'package:i18n_cli/src/key_path.dart';
import 'package:i18n_cli/src/translation_store.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('TranslationStore', () {
    late Directory tempDir;
    late Directory i18nDir;
    late Directory translationsDir;
    late TranslationStore store;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('i18n_cli_test_');
      i18nDir = Directory(p.join(tempDir.path, 'packages', 'i18n'))
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

      store = TranslationStore(
        I18nCliConfig.load(
          workingDirectory: tempDir.path,
          i18nDirectory: i18nDir.path,
        ),
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('adds translations only to provided locales', () {
      final result = store.add(
        key: KeyPath.parse('generic.cancel'),
        translations: {
          'en-US': 'Cancel',
        },
        dryRun: false,
        includeDiff: false,
      );

      expect(result.changedFiles, hasLength(1));
      expect(result.missingLocales, ['vi-VN']);
      expect(
        File(p.join(translationsDir.path, 'en-US.json')).readAsStringSync(),
        contains('"cancel": "Cancel"'),
      );
      expect(
        File(p.join(translationsDir.path, 'vi-VN.json')).readAsStringSync(),
        isNot(contains('cancel')),
      );
    });

    test('dry run reports changes without writing', () {
      store.add(
        key: KeyPath.parse('generic.cancel'),
        translations: {
          'en-US': 'Cancel',
        },
        dryRun: true,
        includeDiff: false,
      );

      expect(
        File(p.join(translationsDir.path, 'en-US.json')).readAsStringSync(),
        isNot(contains('cancel')),
      );
    });

    test('finds missing translations against base locale', () {
      store.add(
        key: KeyPath.parse('generic.cancel'),
        translations: {
          'en-US': 'Cancel',
        },
        dryRun: false,
        includeDiff: false,
      );

      final missing = store.missing(locale: 'vi-VN');

      expect(missing.map((entry) => entry.key), contains('generic.cancel'));
    });

    test('warns about placeholder mismatches', () {
      final result = store.add(
        key: KeyPath.parse('generic.count'),
        translations: {
          'en-US': r'Count $n',
          'vi-VN': 'So luong',
        },
        dryRun: true,
        includeDiff: false,
      );

      expect(result.warnings, contains(contains('missing placeholder')));
    });

    test('prints translation tree', () {
      final tree = store.tree(maxDepth: 1);

      expect(tree, contains('generic\n'));
      expect(tree, contains('  done\n'));
    });

    test('prints translation tree under a prefix', () {
      final tree = store.tree(
        prefix: KeyPath.parse('generic'),
        maxDepth: 0,
      );

      expect(tree, 'generic\n  done\n');
    });

    test('batch add reports existing keys and same-value matches', () {
      final result = store.addBatch(
        parent: KeyPath.parse('generic'),
        locale: 'en-US',
        values: {
          KeyPath.parse('done'): 'Done',
          KeyPath.parse('cancel'): 'Done',
          KeyPath.parse('media'): 'Media',
        },
        dryRun: true,
        includeDiff: true,
      );

      expect(result.addedKeys, ['generic.cancel', 'generic.media']);
      expect(result.existingKeys.map((entry) => entry.key), ['generic.done']);
      expect(
        result.sameValueMatches.map((entry) => entry.existingKey),
        contains('generic.done'),
      );
      expect(result.diffs.single.diff, contains('+    "cancel": "Done",'));
      expect(
        File(p.join(translationsDir.path, 'en-US.json')).readAsStringSync(),
        isNot(contains('cancel')),
      );
    });

    test('adds full keys for manifest use', () {
      final result = store.addKeys(
        locale: 'en-US',
        values: {
          KeyPath.parse('post.action.copy'): 'Copy',
          KeyPath.parse('generic.done'): 'Done',
        },
        dryRun: true,
        includeDiff: true,
      );

      expect(result.addedKeys, ['post.action.copy']);
      expect(result.existingKeys.map((entry) => entry.key), ['generic.done']);
      expect(result.diffs.single.diff, contains('+  "post": {'));
    });

    test('includes diffs when requested', () {
      final result = store.add(
        key: KeyPath.parse('generic.cancel'),
        translations: {
          'en-US': 'Cancel',
        },
        dryRun: true,
        includeDiff: true,
      );

      expect(result.diffs, hasLength(1));
      expect(result.diffs.single.diff, contains('--- '));
      expect(result.diffs.single.diff, contains('+    "cancel": "Cancel"'));
    });
  });
}
