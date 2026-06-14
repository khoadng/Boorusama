import 'package:boorusama_cli/src/release/git/repository.dart';
import 'package:test/test.dart';

void main() {
  group('parseRemoteTagCommit', () {
    test('uses direct ref for lightweight tags', () {
      expect(
        parseRemoteTagCommit(
          'abc123\trefs/tags/v1.2.3',
          'v1.2.3',
        ),
        'abc123',
      );
    });

    test('uses peeled ref for annotated tags', () {
      expect(
        parseRemoteTagCommit(
          [
            'tag-object\trefs/tags/v1.2.3',
            'commit-sha\trefs/tags/v1.2.3^{}',
          ].join('\n'),
          'v1.2.3',
        ),
        'commit-sha',
      );
    });

    test('returns null when tag is missing', () {
      expect(parseRemoteTagCommit('', 'v1.2.3'), isNull);
      expect(parseRemoteTagCommit('unknown', 'v1.2.3'), isNull);
    });
  });
}
