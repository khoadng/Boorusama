import 'package:i18n_cli/src/json_document.dart';
import 'package:i18n_cli/src/key_path.dart';
import 'package:test/test.dart';

void main() {
  group('JsonDocument', () {
    test('adds a nested key with a minimal append patch', () {
      final document = JsonDocument.parse('''
{
  "generic": {
    "done": "Done"
  }
}
''');

      final updated = document.add(
        KeyPath.parse('generic.cancel'),
        'Cancel',
      );

      expect(updated, '''
{
  "generic": {
    "done": "Done",
    "cancel": "Cancel"
  }
}
''');
    });

    test('creates missing parent objects', () {
      final document = JsonDocument.parse('''
{
  "generic": {
    "done": "Done"
  }
}
''');

      final updated = document.add(
        KeyPath.parse('settings.language.title'),
        'Language',
      );

      expect(updated, '''
{
  "generic": {
    "done": "Done"
  },
  "settings": {
    "language": {
      "title": "Language"
    }
  }
}
''');
    });

    test('sets an existing value without rewriting siblings', () {
      final document = JsonDocument.parse('''
{
  "generic": {
    "done": "Done",
    "cancel": "Cancel"
  }
}
''');

      final updated = document.set(
        KeyPath.parse('generic.cancel'),
        'Close',
        create: false,
      );

      expect(updated, '''
{
  "generic": {
    "done": "Done",
    "cancel": "Close"
  }
}
''');
    });

    test('removes the first key with comma handling', () {
      final document = JsonDocument.parse('''
{
  "generic": {
    "done": "Done",
    "cancel": "Cancel"
  }
}
''');

      final updated = document.remove(KeyPath.parse('generic.done'));

      expect(updated, '''
{
  "generic": {
    "cancel": "Cancel"
  }
}
''');
    });

    test('renames a key in place', () {
      final document = JsonDocument.parse('''
{
  "generic": {
    "done": "Done"
  }
}
''');

      final updated = document.rename(
        KeyPath.parse('generic.done'),
        KeyPath.parse('generic.finished'),
      );

      expect(updated, '''
{
  "generic": {
    "finished": "Done"
  }
}
''');
    });
  });
}
