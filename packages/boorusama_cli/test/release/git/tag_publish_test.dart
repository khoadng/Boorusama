import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/release/git/tag_publish.dart';
import 'package:test/test.dart';

void main() {
  group('ReleaseTagPublishStatusService', () {
    test('is pending when no tag exists', () async {
      final repository = _FakeTagRepository(head: 'abc');
      final service = ReleaseTagPublishStatusService(repository);

      expect(await service.isDone(tag: 'v1.2.3', pushTag: true), isFalse);
      expect(repository.pushedTags, isEmpty);
    });

    test('is done when local and remote tags point to HEAD', () async {
      final repository = _FakeTagRepository(
        head: 'abc',
        localTag: 'abc',
        remoteTag: 'abc',
      );
      final service = ReleaseTagPublishStatusService(repository);

      expect(await service.isDone(tag: 'v1.2.3', pushTag: true), isTrue);
      expect(repository.pushedTags, isEmpty);
    });

    test('pushes missing remote tag when local tag points to HEAD', () async {
      final repository = _FakeTagRepository(head: 'abc', localTag: 'abc');
      final service = ReleaseTagPublishStatusService(repository);

      expect(await service.isDone(tag: 'v1.2.3', pushTag: true), isTrue);
      expect(repository.pushedTags, ['v1.2.3']);
    });

    test('is done with local tag only when pushing is disabled', () async {
      final repository = _FakeTagRepository(head: 'abc', localTag: 'abc');
      final service = ReleaseTagPublishStatusService(repository);

      expect(await service.isDone(tag: 'v1.2.3', pushTag: false), isTrue);
      expect(repository.pushedTags, isEmpty);
    });

    test('blocks when local tag points to a different commit', () {
      final repository = _FakeTagRepository(head: 'abc', localTag: 'def');
      final service = ReleaseTagPublishStatusService(repository);

      expect(
        () => service.isDone(tag: 'v1.2.3', pushTag: true),
        throwsA(isA<ProcessFailure>()),
      );
    });

    test('blocks when remote tag points to a different commit', () {
      final repository = _FakeTagRepository(
        head: 'abc',
        localTag: 'abc',
        remoteTag: 'def',
      );
      final service = ReleaseTagPublishStatusService(repository);

      expect(
        () => service.isDone(tag: 'v1.2.3', pushTag: true),
        throwsA(isA<ProcessFailure>()),
      );
    });
  });
}

final class _FakeTagRepository implements ReleaseTagRepository {
  _FakeTagRepository({
    required this.head,
    this.localTag,
    this.remoteTag,
  });

  final String? head;
  final String? localTag;
  final String? remoteTag;
  final pushedTags = <String>[];

  @override
  Future<String?> currentHead() async => head;

  @override
  Future<String?> localTagCommit(String tag) async => localTag;

  @override
  Future<String?> remoteTagCommit(String tag) async => remoteTag;

  @override
  Future<void> pushTag(String tag) async {
    pushedTags.add(tag);
  }
}
