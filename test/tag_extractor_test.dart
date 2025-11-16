// Package imports:
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/tags/categories/types.dart';
import 'package:boorusama/core/tags/local/types.dart';
import 'package:boorusama/core/tags/tag/src/types/cached_tag_mapper.dart';
import 'package:boorusama/core/tags/tag/src/types/tag.dart';
import 'package:boorusama/core/tags/tag/src/types/tag_extractor.dart';

void main() {
  group('CacheWhen', () {
    test('should cache tags with unknown category', () {
      expect(
        CacheWhen.withCache(
          _createResult(
            found: [
              _cachedTag1(
                category: 'unknown',
                postCount: 50,
              ),
            ],
          ),
        )(_tag1()),
        isTrue,
      );
    });

    test('should cache when tag has more posts than cached version', () {
      expect(
        CacheWhen.withCache(
          _createResult(
            found: [
              _cachedTag1(postCount: 50),
            ],
          ),
        )(_tag1()),
        isTrue,
      );
    });

    test('should not cache when post counts match', () {
      expect(
        CacheWhen.withCache(
          _createResult(
            found: [
              _cachedTag1(),
            ],
          ),
        )(_tag1()),
        isFalse,
      );
    });

    test(
      'should cache when cached tag has null postCount but tag has positive postCount',
      () {
        expect(
          CacheWhen.withCache(
            _createResult(
              found: [
                _cachedTag1(postCount: null),
              ],
            ),
          )(_tag1(postCount: 50)),
          isTrue,
        );
      },
    );

    test(
      'should cache when cached tag has zero postCount but tag has positive postCount',
      () {
        expect(
          CacheWhen.withCache(
            _createResult(
              found: [
                _cachedTag1(postCount: 0),
              ],
            ),
          )(_tag1(postCount: 50)),
          isTrue,
        );
      },
    );

    test(
      'should not cache when cached tag has null postCount and tag has zero postCount',
      () {
        expect(
          CacheWhen.withCache(
            _createResult(
              found: [
                _cachedTag1(postCount: null),
              ],
            ),
          )(_tag1(postCount: 0)),
          isFalse,
        );
      },
    );

    test('should not cache when tag is not found in cached tags', () {
      expect(
        CacheWhen.withCache(
          _createResult(
            found: [
              _createCachedTag(
                tagName: 'different_tag',
                category: 'character',
                postCount: 100,
              ),
            ],
          ),
        )(_tag1()),
        isFalse,
      );
    });

    test('should not cache when TagResolutionResult has empty found list', () {
      expect(
        CacheWhen.withCache(
          _createResult(),
        )(_tag1()),
        isFalse,
      );
    });

    test('should not cache when no cached data exists', () {
      expect(
        CacheWhen.withCache(null)(_tag1()),
        isFalse,
      );
    });

    test('should cache when tag is in missing list', () {
      expect(
        CacheWhen.withCache(
          _createResult(missing: ['tag1']),
        )(_tag1()),
        isTrue,
      );
    });

    test('should cache when tag is in missing list with partial hits', () {
      expect(
        CacheWhen.withCache(
          _createResult(
            found: [
              _createCachedTag(
                tagName: 'tag2',
                category: 'character',
                postCount: 100,
              ),
            ],
            missing: ['tag1'],
          ),
        )(_tag1()),
        isTrue,
      );
    });

    test('should handle found tag upgrades when missing list is not empty', () {
      expect(
        CacheWhen.withCache(
          _createResult(
            found: [
              _cachedTag1(category: 'unknown', postCount: 50),
            ],
            missing: ['other_tag'],
          ),
        )(_tag1()),
        isTrue,
      );
    });

    test('should cache when tag has fewer posts than cached version', () {
      // Tags can decrease due to nuking, gardening, etc.
      expect(
        CacheWhen.withCache(
          _createResult(
            found: [
              _cachedTag1(postCount: 150), // cached has more posts
            ],
          ),
        )(
          _tag1(),
        ), // new tag has fewer posts - should still cache
        isTrue,
      );
    });
  });

  group('createCachedTagFetcher', () {
    late MockPost mockPost;
    late MockTagCacheRepository mockTagCache;
    late MockTagFetcher mockFetcher;
    late CachedTagMapper cachedTagMapper;

    setUp(() {
      mockPost = MockPost();
      mockTagCache = MockTagCacheRepository();
      mockFetcher = MockTagFetcher();
      cachedTagMapper = const CachedTagMapper();
      when(() => mockPost.tags).thenReturn({'tag1'});
      registerFallbackValue(mockPost);
      registerFallbackValue(const ExtractOptions());
      // Default stub to prevent null return - using any() for flexibility
      when(() => mockFetcher(any(), any(), any())).thenAnswer((_) async => []);
    });

    test(
      'should return cached tags when cache is complete and fresh',
      () async {
        when(
          () => mockTagCache.resolveTags(any(), any()),
        ).thenAnswer(
          (_) async =>
              TagResolutionResult(found: [_cachedTag1()], missing: const []),
        );

        final fetcher = createCachedTagFetcher(
          siteHost: 'example.com',
          tagCache: Future.value(mockTagCache),
          cachedTagMapper: cachedTagMapper,
          fetcher: mockFetcher.call,
        );

        final tags = await fetcher(mockPost, const ExtractOptions());
        expect(tags[0].name, 'tag1');
      },
    );

    test('should call original fetcher when cache has missing tags', () async {
      when(() => mockTagCache.resolveTags(any(), any())).thenAnswer(
        (_) async => const TagResolutionResult(found: [], missing: ['tag1']),
      );
      _stubMockFetcher(mockFetcher, mockPost);

      await createCachedTagFetcher(
        siteHost: 'example.com',
        tagCache: Future.value(mockTagCache),
        cachedTagMapper: cachedTagMapper,
        fetcher: mockFetcher.call,
      )(mockPost, const ExtractOptions());

      _verifyMockFetcherCalled(mockFetcher, mockPost);
    });

    test('should call original fetcher when cached tags are stale', () async {
      when(() => mockTagCache.resolveTags(any(), any())).thenAnswer(
        (_) async => TagResolutionResult(
          found: [
            CachedTag(
              siteHost: 'example.com',
              tagName: 'tag1',
              category: 'character',
              postCount: 100,
              updatedAt: DateTime.now().subtract(const Duration(days: 35)),
            ),
          ],
          missing: const [],
        ),
      );
      _stubMockFetcher(mockFetcher, mockPost);

      await createCachedTagFetcher(
        siteHost: 'example.com',
        tagCache: Future.value(mockTagCache),
        cachedTagMapper: cachedTagMapper,
        fetcher: mockFetcher.call,
      )(mockPost, const ExtractOptions());

      _verifyMockFetcherCalled(mockFetcher, mockPost);
    });

    test('should call original fetcher when tag count mismatch', () async {
      when(() => mockPost.tags).thenReturn({'tag1', 'tag2'});
      when(
        () => mockTagCache.resolveTags(any(), any()),
      ).thenAnswer(
        (_) async =>
            TagResolutionResult(found: [_cachedTag1()], missing: const []),
      );
      _stubMockFetcher(mockFetcher, mockPost);

      await createCachedTagFetcher(
        siteHost: 'example.com',
        tagCache: Future.value(mockTagCache),
        cachedTagMapper: cachedTagMapper,
        fetcher: mockFetcher.call,
      )(mockPost, const ExtractOptions());

      _verifyMockFetcherCalled(mockFetcher, mockPost);
    });

    test('should call original fetcher when no cache available', () async {
      _stubMockFetcher(mockFetcher, mockPost);

      await createCachedTagFetcher(
        siteHost: 'example.com',
        tagCache: null,
        cachedTagMapper: cachedTagMapper,
        fetcher: mockFetcher.call,
      )(mockPost, const ExtractOptions());

      _verifyMockFetcherCalled(mockFetcher, mockPost);
    });

    test(
      'should use custom expiry when tags are stale by custom rule',
      () async {
        when(
          () => mockTagCache.resolveTags(any(), any()),
        ).thenAnswer(
          (_) async => TagResolutionResult(
            found: [
              CachedTag(
                siteHost: 'example.com',
                tagName: 'tag1',
                category: 'character',
                postCount: 100,
                updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
              ),
            ],
            missing: const [],
          ),
        );
        _stubMockFetcher(mockFetcher, mockPost);

        await createCachedTagFetcher(
          siteHost: 'example.com',
          tagCache: Future.value(mockTagCache),
          cachedTagMapper: cachedTagMapper,
          fetcher: mockFetcher.call,
          cachePolicy: (tag) => const Duration(minutes: 30),
        )(mockPost, const ExtractOptions());

        _verifyMockFetcherCalled(mockFetcher, mockPost);
      },
    );

    test('should call original fetcher when cache has partial hits', () async {
      when(() => mockPost.tags).thenReturn({'tag1', 'tag2'});
      when(() => mockTagCache.resolveTags(any(), any())).thenAnswer(
        (_) async => const TagResolutionResult(
          found: [],
          missing: ['tag1', 'tag2'],
        ),
      );
      _stubMockFetcher(mockFetcher, mockPost);

      await createCachedTagFetcher(
        siteHost: 'example.com',
        tagCache: Future.value(mockTagCache),
        cachedTagMapper: cachedTagMapper,
        fetcher: mockFetcher.call,
      )(mockPost, const ExtractOptions());

      _verifyMockFetcherCalled(mockFetcher, mockPost);
    });

    test(
      'should call original fetcher when cache repository throws error',
      () async {
        when(
          () => mockTagCache.resolveTags(any(), any()),
        ).thenThrow(Exception('Cache error'));
        _stubMockFetcher(mockFetcher, mockPost);

        await createCachedTagFetcher(
          siteHost: 'example.com',
          tagCache: Future.value(mockTagCache),
          cachedTagMapper: cachedTagMapper,
          fetcher: mockFetcher.call,
        )(mockPost, const ExtractOptions());

        _verifyMockFetcherCalled(mockFetcher, mockPost);
      },
    );
  });
}

CachedTag _cachedTag1({String category = 'character', int? postCount = 100}) =>
    CachedTag(
      siteHost: 'example.com',
      tagName: 'tag1',
      category: category,
      postCount: postCount,
      updatedAt: DateTime.now(),
    );

Tag _tag1({int postCount = 100}) => Tag(
  name: 'tag1',
  category: TagCategory.character(),
  postCount: postCount,
);

CachedTag _createCachedTag({
  required String tagName,
  required String category,
  int? postCount,
}) => CachedTag(
  siteHost: 'example.com',
  tagName: tagName,
  category: category,
  postCount: postCount,
);

TagResolutionResult _createResult({
  List<CachedTag> found = const [],
  List<String> missing = const [],
}) => TagResolutionResult(
  found: found,
  missing: missing,
);

class MockPost extends Mock implements Post {}

class MockTagCacheRepository extends Mock implements TagCacheRepository {}

class MockTagFetcher extends Mock {
  Future<List<Tag>> call(
    Post post,
    ExtractOptions options,
    List<String> missing,
  );
}

void _stubMockFetcher(
  MockTagFetcher mockFetcher,
  MockPost mockPost, [
  List<Tag>? tags,
  List<String>? missing,
]) {
  when(
    () => mockFetcher(mockPost, const ExtractOptions(), missing ?? []),
  ).thenAnswer((_) async => tags ?? [_tag1()]);
}

void _verifyMockFetcherCalled(
  MockTagFetcher mockFetcher,
  MockPost mockPost, [
  int times = 1,
]) {
  verify(
    () => mockFetcher(mockPost, const ExtractOptions(), any()),
  ).called(times);
}
