import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/release/play/draft/metadata.dart';
import 'package:test/test.dart';

void main() {
  const builder = PlayReleaseMetadataBuilder();

  test('builds structured API metadata and console preview', () {
    final metadata = builder.build(
      name: '  4.5.0  ',
      changelogSection: '  Release notes  ',
      language: ' en-US ',
    );

    expect(metadata.name, '4.5.0');
    expect(metadata.notes.language, 'en-US');
    expect(metadata.notes.text, 'Release notes');
    expect(metadata.consoleNotes, '<en-US>\nRelease notes\n</en-US>');
  });

  test('rejects release name longer than 50 characters', () {
    expect(
      () => builder.build(
        name: List.filled(51, 'x').join(),
        changelogSection: 'Release notes',
        language: 'en-US',
      ),
      throwsA(isA<ProcessFailure>()),
    );
  });

  test('rejects release notes longer than 500 characters', () {
    expect(
      () => builder.build(
        name: '4.5.0',
        changelogSection: List.filled(501, 'x').join(),
        language: 'en-US',
      ),
      throwsA(isA<ProcessFailure>()),
    );
  });

  test('rejects empty release notes', () {
    expect(
      () => builder.build(
        name: '4.5.0',
        changelogSection: '   ',
        language: 'en-US',
      ),
      throwsA(isA<ProcessFailure>()),
    );
  });

  test('rejects empty language', () {
    expect(
      () => builder.build(
        name: '4.5.0',
        changelogSection: 'Release notes',
        language: '   ',
      ),
      throwsA(isA<ProcessFailure>()),
    );
  });
}
