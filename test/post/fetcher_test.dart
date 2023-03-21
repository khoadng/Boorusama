// Package imports:
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

class MockExploreRepository extends Mock implements ExploreRepository {}

class MockPostRepository extends Mock implements DanbooruPostRepository {}

void main() {
  group('[explore fetcher test]', () {
    final exploreRepo = MockExploreRepository();
    final postRepo = MockPostRepository();

    tearDown(() {
      reset(exploreRepo);
    });

    test('most viewed', () async {
      final fetcher = ExplorePreviewFetcher.now(
        category: ExploreCategory.mostViewed,
        exploreRepository: exploreRepo,
      );

      when(() => exploreRepo.getMostViewedPosts(any()))
          .thenAnswer((invocation) async => [
                DanbooruPost.empty(),
              ]);

      expect(
        await fetcher.fetch(postRepo, 1),
        [DanbooruPost.empty()],
      );
    });

    test('popular', () async {
      final fetcher = ExplorePreviewFetcher.now(
        category: ExploreCategory.popular,
        exploreRepository: exploreRepo,
      );

      when(() => exploreRepo.getPopularPosts(any(), any(), TimeScale.day))
          .thenAnswer((invocation) async => [
                DanbooruPost.empty(),
              ]);

      expect(
        await fetcher.fetch(postRepo, 1),
        [DanbooruPost.empty()],
      );
    });

    test('hot', () async {
      final fetcher = ExplorePreviewFetcher.now(
        category: ExploreCategory.hot,
        exploreRepository: exploreRepo,
      );

      when(() => exploreRepo.getHotPosts(any()))
          .thenAnswer((invocation) async => [
                DanbooruPost.empty(),
              ]);

      expect(
        await fetcher.fetch(postRepo, 1),
        [DanbooruPost.empty()],
      );
    });

    test("fetch yesterday's data if today's data is unavailable", () async {
      final fetcher = ExplorePreviewFetcher(
        category: ExploreCategory.popular,
        date: DateTime(1, 1, 3),
        scale: TimeScale.day,
        exploreRepository: exploreRepo,
      );

      when(() => exploreRepo.getPopularPosts(
            DateTime(1, 1, 3),
            any(),
            TimeScale.day,
          )).thenAnswer((invocation) async => []);

      when(() => exploreRepo.getPopularPosts(
            DateTime(1, 1, 2),
            any(),
            TimeScale.day,
          )).thenAnswer((invocation) async => [
            DanbooruPost.empty(),
          ]);

      expect(
        await fetcher.fetch(postRepo, 1),
        [DanbooruPost.empty()],
      );
    });
  });
}
