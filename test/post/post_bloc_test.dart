// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags_repository.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/domain/error.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockFavoritesRepository extends Mock implements FavoritePostRepository {}

class MockPostVoteRepository extends Mock implements PostVoteRepository {}

class MockPoolRepository extends Mock implements PoolRepository {}

class MockBlacklistedTagsRepository extends Mock
    implements BlacklistedTagsRepository {}

void main() {
  final mockPostRepo = MockPostRepository();
  final mockAccountRepo = MockAccountRepository();
  final mockBlacklistedRepo = MockBlacklistedTagsRepository();
  final mockFavRepo = MockFavoritesRepository();
  final mockPostVoteRepo = MockPostVoteRepository();
  final mockPoolRepo = MockPoolRepository();
  group('[post bloc failure test]', () {
    blocTest<PostBloc, PostState>(
      'tag limit',
      setUp: () {
        when(() => mockPostRepo.getPosts(any(), any()))
            .thenThrow(BooruError(error: ServerError(httpStatusCode: 422)));
      },
      tearDown: () => reset(mockPostRepo),
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.tag_limit',
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      'time out',
      setUp: () {
        when(() => mockPostRepo.getPosts(any(), any()))
            .thenThrow(BooruError(error: ServerError(httpStatusCode: 500)));
      },
      tearDown: () => reset(mockPostRepo),
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.database_timeout',
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      'unknown',
      setUp: () {
        when(() => mockPostRepo.getPosts(any(), any()))
            .thenThrow(BooruError(error: Error()));
      },
      tearDown: () => reset(mockPostRepo),
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.unknown',
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      'unknown server error when favorites repo failed',
      setUp: () {
        when(() => mockPostRepo.getPosts(any(), any()))
            .thenAnswer((invocation) async => [
                  Post.empty(),
                  Post.empty(),
                ]);
        when(() => mockAccountRepo.get()).thenAnswer((invocation) async =>
            const Account(id: 1, apiKey: '', username: ''));
        when(() => mockBlacklistedRepo.getBlacklistedTags())
            .thenAnswer((invocation) async => []);
        when(() => mockFavRepo.filterFavoritesFromUserId(any(), any(), any()))
            .thenThrow(Error());
        when(() => mockPoolRepo.getPoolsByPostIds(any()))
            .thenAnswer((invocation) async => []);
        when(() => mockPostVoteRepo.getPostVotes(any()))
            .thenAnswer((invocation) async => []);
      },
      tearDown: () {
        reset(mockPostRepo);
        reset(mockAccountRepo);
        reset(mockBlacklistedRepo);
        reset(mockFavRepo);
        reset(mockPoolRepo);
        reset(mockPostVoteRepo);
      },
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.unknown',
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      'unknown server error when fetch more',
      setUp: () {
        when(() => mockPostRepo.getPosts(any(), any()))
            .thenThrow(BooruError(error: ServerError(httpStatusCode: 9999)));
      },
      tearDown: () => reset(mockPostRepo),
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostFetched(tags: '', fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial().copyWith(status: LoadStatus.loading),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.unknown',
        ),
      ],
    );
  });

  group('[post bloc success]', () {
    blocTest<PostBloc, PostState>(
      '2 posts returned',
      setUp: () {
        when(() => mockPostRepo.getPosts(any(), any()))
            .thenAnswer((invocation) async => [
                  Post.empty(),
                  Post.empty(),
                ]);
        when(() => mockAccountRepo.get())
            .thenAnswer((invocation) async => Account.empty);
        when(() => mockBlacklistedRepo.getBlacklistedTags())
            .thenAnswer((invocation) async => []);
        when(() => mockFavRepo.getFavorites(any(), any()))
            .thenAnswer((invocation) async => []);
        when(() => mockPoolRepo.getPoolsByPostIds(any()))
            .thenAnswer((invocation) async => []);
      },
      tearDown: () {
        reset(mockPostRepo);
        reset(mockAccountRepo);
        reset(mockBlacklistedRepo);
        reset(mockFavRepo);
        reset(mockPoolRepo);
      },
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.success,
          posts: [
            PostData.empty(),
            PostData.empty(),
          ],
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      '2 posts returned, non-anon user',
      setUp: () {
        when(() => mockPostRepo.getPosts(any(), any()))
            .thenAnswer((invocation) async => [
                  Post.empty(),
                  Post.empty(),
                ]);
        when(() => mockAccountRepo.get()).thenAnswer((invocation) async =>
            const Account(id: 1, apiKey: '', username: ''));
        when(() => mockBlacklistedRepo.getBlacklistedTags())
            .thenAnswer((invocation) async => []);
        when(() => mockFavRepo.filterFavoritesFromUserId(any(), any(), any()))
            .thenAnswer((invocation) async => []);
        when(() => mockPoolRepo.getPoolsByPostIds(any()))
            .thenAnswer((invocation) async => []);
        when(() => mockPostVoteRepo.getPostVotes(any()))
            .thenAnswer((invocation) async => []);
      },
      tearDown: () {
        reset(mockPostRepo);
        reset(mockAccountRepo);
        reset(mockBlacklistedRepo);
        reset(mockFavRepo);
        reset(mockPoolRepo);
        reset(mockPostVoteRepo);
      },
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.success,
          posts: [
            PostData.empty(),
            PostData.empty(),
          ],
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      '2 posts returned with pools',
      setUp: () {
        when(() => mockPostRepo.getPosts(any(), any()))
            .thenAnswer((invocation) async => [
                  Post.empty().copyWith(id: 1),
                  Post.empty().copyWith(id: 2),
                ]);
        when(() => mockAccountRepo.get())
            .thenAnswer((invocation) async => Account.empty);
        when(() => mockBlacklistedRepo.getBlacklistedTags())
            .thenAnswer((invocation) async => []);
        when(() => mockFavRepo.getFavorites(any(), any()))
            .thenAnswer((invocation) async => []);
        when(() => mockPoolRepo.getPoolsByPostIds(any()))
            .thenAnswer((invocation) async => [
                  Pool.empty().copyWith(id: 11, postIds: [1, 100]),
                  Pool.empty().copyWith(id: 22, postIds: [2, 200]),
                  Pool.empty().copyWith(id: 33, postIds: [2, 201]),
                  Pool.empty().copyWith(id: 44, postIds: [2, 202]),
                ]);
      },
      tearDown: () {
        reset(mockPostRepo);
        reset(mockAccountRepo);
        reset(mockBlacklistedRepo);
        reset(mockFavRepo);
        reset(mockPoolRepo);
      },
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.success,
          posts: [
            PostData.empty().copyWith(
              post: Post.empty().copyWith(id: 1),
              pools: [
                Pool.empty().copyWith(id: 11, postIds: [1, 100]),
              ],
            ),
            PostData.empty().copyWith(
              post: Post.empty().copyWith(id: 2),
              pools: [
                Pool.empty().copyWith(id: 22, postIds: [2, 200]),
                Pool.empty().copyWith(id: 33, postIds: [2, 201]),
                Pool.empty().copyWith(id: 44, postIds: [2, 202]),
              ],
            ),
          ],
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      '2 posts initial + 1 posts returned',
      setUp: () {
        when(() => mockPostRepo.getPosts(any(), any()))
            .thenAnswer((invocation) async => [
                  Post.empty(),
                ]);
        when(() => mockAccountRepo.get())
            .thenAnswer((invocation) async => Account.empty);
        when(() => mockBlacklistedRepo.getBlacklistedTags())
            .thenAnswer((invocation) async => []);
        when(() => mockFavRepo.getFavorites(any(), any()))
            .thenAnswer((invocation) async => []);
        when(() => mockPoolRepo.getPoolsByPostIds(any()))
            .thenAnswer((invocation) async => []);
      },
      seed: () => PostState.initial().copyWith(
        page: 1,
        posts: [
          PostData.empty(),
          PostData.empty(),
        ],
      ),
      tearDown: () {
        reset(mockPostRepo);
        reset(mockAccountRepo);
        reset(mockBlacklistedRepo);
        reset(mockFavRepo);
        reset(mockPoolRepo);
      },
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostFetched(tags: '', fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial().copyWith(
          status: LoadStatus.loading,
          posts: [
            PostData.empty(),
            PostData.empty(),
          ],
        ),
        PostState.initial().copyWith(
          page: 2,
          status: LoadStatus.success,
          posts: [
            PostData.empty(),
            PostData.empty(),
            PostData.empty(),
          ],
        ),
      ],
    );
  });

  group('[post bloc item update]', () {
    blocTest<PostBloc, PostState>(
      '3 posts initial, update the middle post',
      seed: () => PostState.initial().copyWith(
        page: 1,
        posts: [
          PostData.empty().copyWith(post: Post.empty().copyWith(id: 1)),
          PostData.empty().copyWith(post: Post.empty().copyWith(id: 2)),
          PostData.empty().copyWith(post: Post.empty().copyWith(id: 3)),
        ],
      ),
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
        stateIdGenerator: () => 123,
      ),
      act: (bloc) => bloc.add(PostUpdated(
        post: Post.empty().copyWith(
          id: 2,
          tags: ['foo'],
        ),
      )),
      expect: () => [
        PostState.initial().copyWith(
          id: 123,
          posts: [
            PostData.empty().copyWith(post: Post.empty().copyWith(id: 1)),
            PostData.empty().copyWith(
              post: Post.empty().copyWith(id: 2, tags: ['foo']),
            ),
            PostData.empty().copyWith(post: Post.empty().copyWith(id: 3)),
          ],
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      '3 posts initial, update the non-exist post',
      seed: () => PostState.initial().copyWith(
        page: 1,
        posts: [
          PostData.empty().copyWith(post: Post.empty().copyWith(id: 1)),
          PostData.empty().copyWith(post: Post.empty().copyWith(id: 2)),
          PostData.empty().copyWith(post: Post.empty().copyWith(id: 3)),
        ],
      ),
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        poolRepository: mockPoolRepo,
        stateIdGenerator: () => 123,
      ),
      act: (bloc) => bloc.add(PostUpdated(
        post: Post.empty().copyWith(
          id: 4,
          tags: ['foo'],
        ),
      )),
      expect: () => [],
    );
  });
}
