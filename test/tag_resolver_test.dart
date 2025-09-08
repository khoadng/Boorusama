// Package imports:
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/tags/local/cached_tag.dart';
import 'package:boorusama/core/tags/local/tag_cache_repository.dart';
import 'package:boorusama/core/tags/tag/src/types/cached_tag_mapper.dart';
import 'package:boorusama/core/tags/tag/src/types/tag.dart';
import 'package:boorusama/core/tags/tag/src/types/tag_repository.dart';
import 'package:boorusama/core/tags/tag/src/types/tag_resolver.dart';

class MockTagCacheRepository extends Mock implements TagCacheRepository {}

class MockTagRepository extends Mock implements TagRepository {}

class MockCachedTagMapper extends Mock implements CachedTagMapper {}

class TagCacheException implements Exception {
  const TagCacheException(this.message);
  final String message;
  @override
  String toString() => 'TagCacheException: $message';
}

class TagRepositoryException implements Exception {
  const TagRepositoryException(this.message);
  final String message;
  @override
  String toString() => 'TagRepositoryException: $message';
}

// Test constants
class TestConstants {
  static const siteHost = 'test.com';
  static const shortCacheLifetime = Duration(hours: 6);
  static const mediumCacheLifetime = Duration(days: 2);
  static const staleAge = Duration(days: 1);
  static const freshAge = Duration(minutes: 30);
}

// Test helper methods
class TestHelpers {
  static Tag createTag(String name, int postCount) {
    return Tag.empty().copyWith(name, null, postCount);
  }

  static CachedTag createCachedTag(
    String name, {
    String category = 'general',
    int? postCount = 100,
    Duration? age,
  }) {
    return CachedTag(
      siteHost: TestConstants.siteHost,
      tagName: name,
      category: category,
      postCount: postCount,
      updatedAt: DateTime.now().toUtc().subtract(age ?? Duration.zero),
    );
  }

  static TagResolutionResult createResolutionResult({
    List<CachedTag> found = const [],
    List<String> missing = const [],
  }) {
    return TagResolutionResult(found: found, missing: missing);
  }

  static void expectTagWithPostCount(Tag tag, String name, int postCount) {
    expect(tag.name, equals(name));
    expect(tag.postCount, equals(postCount));
  }
}

void main() {
  group('TagResolver', () {
    late TagResolver tagResolver;
    late MockTagCacheRepository mockTagCache;
    late MockTagRepository mockTagRepository;
    late MockCachedTagMapper mockCachedTagMapper;

    setUp(() {
      mockTagCache = MockTagCacheRepository();
      mockTagRepository = MockTagRepository();
      mockCachedTagMapper = MockCachedTagMapper();

      tagResolver = TagResolver(
        tagCacheBuilder: () async => mockTagCache,
        siteHost: TestConstants.siteHost,
        cachedTagMapper: mockCachedTagMapper,
        tagRepositoryBuilder: () => mockTagRepository,
      );
    });

    group('Resolve partial tags', () {
      test(
        'returns tags unchanged when all have non-zero post count',
        () async {
          final tags = [
            TestHelpers.createTag('tag1', 100),
            TestHelpers.createTag('tag2', 50),
          ];

          final result = await tagResolver.resolvePartialTags(tags);
          expect(result, equals(tags));
        },
      );

      test('resolves tags with zero post count from cache', () async {
        final inputTags = [
          TestHelpers.createTag('tag1', 0),
          TestHelpers.createTag('tag2', 100),
        ];

        final cachedTags = [
          TestHelpers.createCachedTag('tag1', postCount: 200),
        ];

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, ['tag1']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: cachedTags,
          ),
        );

        final result = await tagResolver.resolvePartialTags(inputTags);

        expect(result, hasLength(2));
        TestHelpers.expectTagWithPostCount(result[0], 'tag1', 200);
        TestHelpers.expectTagWithPostCount(result[1], 'tag2', 100);
      });
    });

    group('Resolve raw tags', () {
      test('resolves raw tag names to Tag objects', () async {
        const tagNames = ['tag1', 'tag2'];

        final cachedTags = [TestHelpers.createCachedTag('tag1')];
        final expectedTags = [TestHelpers.createTag('tag1', 100)];

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, tagNames),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: cachedTags,
            missing: ['tag2'],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'tag2'}, 1),
        ).thenAnswer((_) async => []);

        when(
          () => mockCachedTagMapper.mapCachedTagsToTags(any()),
        ).thenReturn(expectedTags);

        final result = await tagResolver.resolveRawTags(tagNames);

        expect(result, isNotEmpty);
        verify(() => mockCachedTagMapper.mapCachedTagsToTags(any())).called(1);
      });

      test(
        'filters out resolved tags from found tags to prevent duplicates',
        () async {
          const tagNames = ['duplicate_tag'];

          final staleCachedTag = TestHelpers.createCachedTag(
            'duplicate_tag',
            age: const Duration(days: 1),
          );

          final freshResolvedTag = TestHelpers.createTag('duplicate_tag', 150);

          when(
            () => mockTagCache.resolveTags(TestConstants.siteHost, tagNames),
          ).thenAnswer(
            (_) async => TestHelpers.createResolutionResult(
              found: [staleCachedTag],
            ),
          );

          when(
            () => mockTagRepository.getTagsByName({'duplicate_tag'}, 1),
          ).thenAnswer((_) async => [freshResolvedTag]);

          when(
            () => mockCachedTagMapper.mapCachedTagsToTags(any()),
          ).thenReturn([freshResolvedTag]);

          final result = await tagResolver.resolveRawTags(tagNames);

          expect(result, hasLength(1));
          expect(result[0].postCount, equals(150));

          final capturedArgs =
              verify(
                    () => mockCachedTagMapper.mapCachedTagsToTags(captureAny()),
                  ).captured.last
                  as List<CachedTag>;
          expect(
            capturedArgs.where((tag) => tag.tagName == 'duplicate_tag'),
            hasLength(1),
          );
        },
      );
    });

    group('Error handling', () {
      test('handles repository errors gracefully', () async {
        final inputTags = [TestHelpers.createTag('error_tag', 0)];

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, ['error_tag']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            missing: ['error_tag'],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'error_tag'}, 1),
        ).thenThrow(const TagRepositoryException('Network error'));

        final result = await tagResolver.resolvePartialTags(inputTags);

        expect(result, hasLength(1));
        TestHelpers.expectTagWithPostCount(result[0], 'error_tag', 0);
      });

      test('handles cache builder exceptions', () {
        final inputTags = [TestHelpers.createTag('test_tag', 0)];

        final failingTagResolver = TagResolver(
          tagCacheBuilder: () async =>
              throw const TagCacheException('Cache unavailable'),
          siteHost: TestConstants.siteHost,
          cachedTagMapper: mockCachedTagMapper,
          tagRepositoryBuilder: () => mockTagRepository,
        );

        expect(
          () => failingTagResolver.resolvePartialTags(inputTags),
          throwsA(
            isA<TagCacheException>().having(
              (e) => e.message,
              'message',
              'Cache unavailable',
            ),
          ),
        );
      });
    });

    group('Without tag repository', () {
      setUp(() {
        tagResolver = TagResolver(
          tagCacheBuilder: () async => mockTagCache,
          siteHost: TestConstants.siteHost,
          cachedTagMapper: mockCachedTagMapper,
        );
      });

      test('skips repository resolution when not available', () async {
        final inputTags = [TestHelpers.createTag('missing_tag', 0)];

        when(
          () =>
              mockTagCache.resolveTags(TestConstants.siteHost, ['missing_tag']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            missing: ['missing_tag'],
          ),
        );

        final result = await tagResolver.resolvePartialTags(inputTags);

        expect(result, hasLength(1));
        TestHelpers.expectTagWithPostCount(result[0], 'missing_tag', 0);
      });
    });

    group('Stale tag refresh', () {
      test('refreshes stale tags when they are outdated', () async {
        final inputTags = [TestHelpers.createTag('stale_tag', 0)];
        final staleCachedTag = TestHelpers.createCachedTag(
          'stale_tag',
          postCount: 50,
          age: TestConstants.staleAge,
        );
        final refreshedTag = TestHelpers.createTag('stale_tag', 100);

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, ['stale_tag']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [staleCachedTag],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'stale_tag'}, 1),
        ).thenAnswer((_) async => [refreshedTag]);

        when(() => mockTagCache.saveTagsBatch(any())).thenAnswer((_) async {});

        final result = await tagResolver.resolvePartialTags(inputTags);

        TestHelpers.expectTagWithPostCount(result[0], 'stale_tag', 100);
        verify(
          () => mockTagRepository.getTagsByName({'stale_tag'}, 1),
        ).called(1);
        verify(() => mockTagCache.saveTagsBatch(any())).called(1);
      });

      test('keeps stale tags unchanged when repository fails', () async {
        final inputTags = [TestHelpers.createTag('stale_tag', 0)];
        final staleCachedTag = TestHelpers.createCachedTag(
          'stale_tag',
          postCount: 50,
          age: TestConstants.staleAge,
        );

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, ['stale_tag']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [staleCachedTag],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'stale_tag'}, 1),
        ).thenThrow(const TagRepositoryException('Repository error'));

        final result = await tagResolver.resolvePartialTags(inputTags);

        TestHelpers.expectTagWithPostCount(result[0], 'stale_tag', 50);
      });

      test('does not refresh fresh tags', () async {
        final inputTags = [TestHelpers.createTag('fresh_tag', 0)];
        final freshCachedTag = TestHelpers.createCachedTag(
          'fresh_tag',
          postCount: 75,
          age: TestConstants.freshAge,
        );

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, ['fresh_tag']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [freshCachedTag],
          ),
        );

        final result = await tagResolver.resolvePartialTags(inputTags);

        TestHelpers.expectTagWithPostCount(result[0], 'fresh_tag', 75);
        verifyNever(() => mockTagRepository.getTagsByName(any(), any()));
      });
    });

    group('Cache lifetime intervals', () {
      test('refreshes stale tags based on post count thresholds', () async {
        final inputTags = [TestHelpers.createTag('stale_tag', 0)];
        final staleCachedTag = TestHelpers.createCachedTag(
          'stale_tag',
          postCount: 500,
          age: TestConstants.mediumCacheLifetime + const Duration(days: 1),
        );

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, ['stale_tag']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [staleCachedTag],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'stale_tag'}, 1),
        ).thenAnswer((_) async => [TestHelpers.createTag('stale_tag', 600)]);

        when(() => mockTagCache.saveTagsBatch(any())).thenAnswer((_) async {});

        await tagResolver.resolvePartialTags(inputTags);

        verify(
          () => mockTagRepository.getTagsByName({'stale_tag'}, 1),
        ).called(1);
      });
    });

    group('Null post count handling', () {
      test('treats tags with null post count as needing resolution', () async {
        final inputTags = [TestHelpers.createTag('null_tag', 0)];
        final nullCountCachedTag = TestHelpers.createCachedTag(
          'null_tag',
          postCount: null,
        );

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, ['null_tag']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [nullCountCachedTag],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'null_tag'}, 1),
        ).thenAnswer((_) async => [TestHelpers.createTag('null_tag', 150)]);

        final result = await tagResolver.resolvePartialTags(inputTags);

        TestHelpers.expectTagWithPostCount(result[0], 'null_tag', 150);
        verify(
          () => mockTagRepository.getTagsByName({'null_tag'}, 1),
        ).called(1);
      });

      test('handles mix of null and zero post counts', () async {
        final inputTags = [
          TestHelpers.createTag('null_tag', 0),
          TestHelpers.createTag('zero_tag', 0),
        ];
        final nullCountCachedTag = TestHelpers.createCachedTag(
          'null_tag',
          postCount: null,
        );

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, [
            'null_tag',
            'zero_tag',
          ]),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [nullCountCachedTag],
            missing: ['zero_tag'],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'null_tag', 'zero_tag'}, 1),
        ).thenAnswer(
          (_) async => [
            TestHelpers.createTag('null_tag', 100),
            TestHelpers.createTag('zero_tag', 200),
          ],
        );

        final result = await tagResolver.resolvePartialTags(inputTags);

        TestHelpers.expectTagWithPostCount(result[0], 'null_tag', 100);
        TestHelpers.expectTagWithPostCount(result[1], 'zero_tag', 200);
      });
    });

    group('Unknown tag category handling', () {
      test('resolves unknown category tags from repository', () async {
        const tagNames = ['unknown_tag'];

        final unknownCachedTag = TestHelpers.createCachedTag(
          'unknown_tag',
          category: 'unknown',
          postCount: 50,
        );

        final resolvedTag = TestHelpers.createTag('unknown_tag', 100);

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, tagNames),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [unknownCachedTag],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'unknown_tag'}, 1),
        ).thenAnswer((_) async => [resolvedTag]);

        when(
          () => mockCachedTagMapper.mapCachedTagsToTags(any()),
        ).thenReturn([resolvedTag]);

        await tagResolver.resolveRawTags(tagNames);

        verify(
          () => mockTagRepository.getTagsByName({'unknown_tag'}, 1),
        ).called(1);
        verify(() => mockCachedTagMapper.mapCachedTagsToTags(any())).called(1);
      });

      test(
        'creates unknown tags for missing tags that cannot be resolved',
        () async {
          const tagNames = ['missing_tag'];

          when(
            () => mockTagCache.resolveTags(TestConstants.siteHost, tagNames),
          ).thenAnswer(
            (_) async => TestHelpers.createResolutionResult(
              missing: ['missing_tag'],
            ),
          );

          when(
            () => mockTagRepository.getTagsByName({'missing_tag'}, 1),
          ).thenAnswer((_) async => []);

          when(
            () => mockCachedTagMapper.mapCachedTagsToTags(any()),
          ).thenReturn([TestHelpers.createTag('missing_tag', 0)]);

          await tagResolver.resolveRawTags(tagNames);

          final capturedArgs =
              verify(
                    () => mockCachedTagMapper.mapCachedTagsToTags(captureAny()),
                  ).captured.last
                  as List<CachedTag>;
          expect(
            capturedArgs.any(
              (tag) => tag.tagName == 'missing_tag' && tag.category == '',
            ),
            isTrue,
          );
        },
      );

      test(
        'filters stillMissingTags correctly when some missing tags get resolved',
        () async {
          const tagNames = ['missing1', 'missing2'];

          when(
            () => mockTagCache.resolveTags(TestConstants.siteHost, tagNames),
          ).thenAnswer(
            (_) async => TestHelpers.createResolutionResult(
              missing: ['missing1', 'missing2'],
            ),
          );

          when(
            () => mockTagRepository.getTagsByName({'missing1', 'missing2'}, 1),
          ).thenAnswer(
            (_) async => [TestHelpers.createTag('missing1', 100)],
          );

          when(() => mockCachedTagMapper.mapCachedTagsToTags(any())).thenReturn(
            [
              TestHelpers.createTag('missing1', 100),
              TestHelpers.createTag('missing2', 0),
            ],
          );

          await tagResolver.resolveRawTags(tagNames);

          final capturedArgs =
              verify(
                    () => mockCachedTagMapper.mapCachedTagsToTags(captureAny()),
                  ).captured.last
                  as List<CachedTag>;
          expect(
            capturedArgs.where((tag) => tag.tagName == 'missing1').length,
            1,
          );
          expect(
            capturedArgs
                .where((tag) => tag.tagName == 'missing2' && tag.category == '')
                .length,
            1,
          );
        },
      );

      test('re-resolves unknown cached tags', () async {
        const tagNames = ['unknown_cached'];

        final unknownCachedTag = TestHelpers.createCachedTag(
          'unknown_cached',
          category: 'unknown',
          postCount: 50,
        );

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, tagNames),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [unknownCachedTag],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'unknown_cached'}, 1),
        ).thenAnswer(
          (_) async => [TestHelpers.createTag('unknown_cached', 200)],
        );

        when(
          () => mockCachedTagMapper.mapCachedTagsToTags(any()),
        ).thenReturn([TestHelpers.createTag('unknown_cached', 200)]);

        await tagResolver.resolveRawTags(tagNames);

        verify(
          () => mockTagRepository.getTagsByName({'unknown_cached'}, 1),
        ).called(1);
        final capturedArgs =
            verify(
                  () => mockCachedTagMapper.mapCachedTagsToTags(captureAny()),
                ).captured.last
                as List<CachedTag>;
        expect(
          capturedArgs.any(
            (tag) => tag.tagName == 'unknown_cached' && tag.postCount == 200,
          ),
          isTrue,
        );
        expect(
          capturedArgs.where((tag) => tag.tagName == 'unknown_cached').length,
          1,
        );
      });
    });

    group('Advanced filtering and deduplication', () {
      test(
        'set deduplication prevents duplicates across found/resolved/stillMissing',
        () async {
          const tagNames = ['duplicate_across_collections'];

          final foundTag = TestHelpers.createCachedTag(
            'duplicate_across_collections',
            age: const Duration(days: 1),
          );

          when(
            () => mockTagCache.resolveTags(TestConstants.siteHost, tagNames),
          ).thenAnswer(
            (_) async => TestHelpers.createResolutionResult(
              found: [foundTag],
              missing: ['duplicate_across_collections'],
            ),
          );

          when(
            () => mockTagRepository.getTagsByName({
              'duplicate_across_collections',
            }, 1),
          ).thenAnswer(
            (_) async => [
              TestHelpers.createTag('duplicate_across_collections', 200),
            ],
          );

          when(() => mockCachedTagMapper.mapCachedTagsToTags(any())).thenReturn(
            [TestHelpers.createTag('duplicate_across_collections', 200)],
          );

          await tagResolver.resolveRawTags(tagNames);

          final capturedArgs =
              verify(
                    () => mockCachedTagMapper.mapCachedTagsToTags(captureAny()),
                  ).captured.last
                  as List<CachedTag>;
          expect(
            capturedArgs
                .where((tag) => tag.tagName == 'duplicate_across_collections')
                .length,
            1,
          );
          expect(capturedArgs.single.postCount, 200);
        },
      );

      test(
        'preserves unchangedStale tags when repository partially fails',
        () async {
          final inputTags = [
            TestHelpers.createTag('stale1', 0),
            TestHelpers.createTag('stale2', 0),
          ];

          final staleCachedTags = [
            TestHelpers.createCachedTag(
              'stale1',
              postCount: 50,
              age: const Duration(days: 1),
            ),
            TestHelpers.createCachedTag(
              'stale2',
              postCount: 75,
              age: const Duration(days: 1),
            ),
          ];

          when(
            () => mockTagCache.resolveTags(TestConstants.siteHost, [
              'stale1',
              'stale2',
            ]),
          ).thenAnswer(
            (_) async => TestHelpers.createResolutionResult(
              found: staleCachedTags,
            ),
          );

          when(
            () => mockTagRepository.getTagsByName({'stale1', 'stale2'}, 1),
          ).thenAnswer(
            (_) async => [TestHelpers.createTag('stale1', 100)],
          );

          when(
            () => mockTagCache.saveTagsBatch(any()),
          ).thenAnswer((_) async {});

          final result = await tagResolver.resolvePartialTags(inputTags);

          expect(result[0].postCount, equals(100));
          expect(result[1].postCount, equals(75));
          verify(() => mockTagCache.saveTagsBatch(any())).called(1);
        },
      );

      test('handles complex scenario with multiple resolution paths', () async {
        const tagNames = ['fresh_tag', 'missing_tag'];

        final cachedTags = [
          TestHelpers.createCachedTag(
            'fresh_tag',
            age: const Duration(minutes: 30),
          ),
        ];

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, tagNames),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: cachedTags,
            missing: ['missing_tag'],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'missing_tag'}, 1),
        ).thenAnswer((_) async => []);

        when(() => mockCachedTagMapper.mapCachedTagsToTags(any())).thenReturn([
          TestHelpers.createTag('fresh_tag', 100),
          TestHelpers.createTag('missing_tag', 0),
        ]);

        final result = await tagResolver.resolveRawTags(tagNames);

        expect(result, hasLength(2));
        final capturedArgs =
            verify(
                  () => mockCachedTagMapper.mapCachedTagsToTags(captureAny()),
                ).captured.last
                as List<CachedTag>;

        expect(
          capturedArgs
              .where((tag) => tag.tagName == 'fresh_tag')
              .single
              .postCount,
          100,
        );
        expect(
          capturedArgs.where(
            (tag) => tag.tagName == 'missing_tag' && tag.category == '',
          ),
          hasLength(1),
        );
      });
    });

    group('Cache builder failures', () {
      test('handles cache builder throwing exception', () {
        final inputTags = [TestHelpers.createTag('test_tag', 0)];

        final failingTagResolver = TagResolver(
          tagCacheBuilder: () async =>
              throw const TagCacheException('Cache error'),
          siteHost: TestConstants.siteHost,
          cachedTagMapper: mockCachedTagMapper,
          tagRepositoryBuilder: () => mockTagRepository,
        );

        expect(
          () => failingTagResolver.resolvePartialTags(inputTags),
          throwsA(isA<TagCacheException>()),
        );
      });

      test('handles cache builder with different error types', () {
        const tagNames = ['test_tag'];

        final nullCacheTagResolver = TagResolver(
          tagCacheBuilder: () async =>
              throw const TagCacheException('Cache initialization failed'),
          siteHost: TestConstants.siteHost,
          cachedTagMapper: mockCachedTagMapper,
          tagRepositoryBuilder: () => mockTagRepository,
        );

        expect(
          () => nullCacheTagResolver.resolveRawTags(tagNames),
          throwsA(
            isA<TagCacheException>().having(
              (e) => e.message,
              'message',
              'Cache initialization failed',
            ),
          ),
        );
      });
    });

    group('Mixed scenarios', () {
      test('handles multiple tags with different resolution needs', () async {
        final inputTags = [
          TestHelpers.createTag('fresh_tag', 0),
          TestHelpers.createTag('missing_tag', 0),
        ];

        final cachedTags = [
          TestHelpers.createCachedTag(
            'fresh_tag',
            age: const Duration(minutes: 30),
          ),
        ];

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, [
            'fresh_tag',
            'missing_tag',
          ]),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: cachedTags,
            missing: ['missing_tag'],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'missing_tag'}, 1),
        ).thenAnswer(
          (_) async => [TestHelpers.createTag('missing_tag', 300)],
        );

        final result = await tagResolver.resolvePartialTags(inputTags);

        expect(result[0].postCount, equals(100)); // fresh_tag unchanged
        expect(result[1].postCount, equals(300)); // missing_tag resolved

        verify(
          () => mockTagRepository.getTagsByName({'missing_tag'}, 1),
        ).called(1);
      });

      test('handles partial repository failures in mixed scenario', () async {
        final inputTags = [
          TestHelpers.createTag('stale_tag', 0),
          TestHelpers.createTag('missing_tag', 0),
        ];

        final staleCachedTag = TestHelpers.createCachedTag(
          'stale_tag',
          age: const Duration(days: 1),
        );

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, [
            'stale_tag',
            'missing_tag',
          ]),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [staleCachedTag],
            missing: ['missing_tag'],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'stale_tag'}, 1),
        ).thenThrow(Exception('Stale tag refresh failed'));

        when(
          () => mockTagRepository.getTagsByName({'missing_tag'}, 1),
        ).thenAnswer(
          (_) async => [TestHelpers.createTag('missing_tag', 200)],
        );

        final result = await tagResolver.resolvePartialTags(inputTags);

        expect(
          result[0].postCount,
          equals(100),
        ); // stale_tag unchanged due to error
        expect(
          result[1].postCount,
          equals(200),
        ); // missing_tag resolved successfully
      });
    });

    group('Repository integration', () {
      test('calls repository when tag repository is available', () async {
        final inputTags = [TestHelpers.createTag('missing_tag', 0)];

        when(
          () =>
              mockTagCache.resolveTags(TestConstants.siteHost, ['missing_tag']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            missing: ['missing_tag'],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'missing_tag'}, 1),
        ).thenAnswer(
          (_) async => [TestHelpers.createTag('missing_tag', 200)],
        );

        final result = await tagResolver.resolvePartialTags(inputTags);

        expect(result[0].postCount, equals(200));
        verify(
          () => mockTagRepository.getTagsByName({'missing_tag'}, 1),
        ).called(1);
      });

      test('handles repository exceptions gracefully', () async {
        final inputTags = [TestHelpers.createTag('error_tag', 0)];

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, ['error_tag']),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            missing: ['error_tag'],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'error_tag'}, 1),
        ).thenThrow(const TagRepositoryException('Repository error'));

        final result = await tagResolver.resolvePartialTags(inputTags);

        TestHelpers.expectTagWithPostCount(result[0], 'error_tag', 0);
        verify(
          () => mockTagRepository.getTagsByName({'error_tag'}, 1),
        ).called(1);
      });
    });

    group('Edge cases and boundary conditions', () {
      test('handles exactly at cache lifetime boundary', () async {
        final inputTags = [TestHelpers.createTag('boundary_tag', 0)];
        final boundaryCachedTag = TestHelpers.createCachedTag(
          'boundary_tag',
          postCount: 50, // Less than 100, so uses short lifetime
          age: TestConstants.shortCacheLifetime + const Duration(hours: 1),
        );

        when(
          () => mockTagCache.resolveTags(TestConstants.siteHost, [
            'boundary_tag',
          ]),
        ).thenAnswer(
          (_) async => TestHelpers.createResolutionResult(
            found: [boundaryCachedTag],
          ),
        );

        when(
          () => mockTagRepository.getTagsByName({'boundary_tag'}, 1),
        ).thenAnswer((_) async => [TestHelpers.createTag('boundary_tag', 150)]);

        when(() => mockTagCache.saveTagsBatch(any())).thenAnswer((_) async {});

        final result = await tagResolver.resolvePartialTags(inputTags);

        // The tag should be refreshed from cache first, then from repository if stale
        TestHelpers.expectTagWithPostCount(result[0], 'boundary_tag', 150);
        verify(
          () => mockTagRepository.getTagsByName({'boundary_tag'}, 1),
        ).called(1);
      });
    });
  });
}
