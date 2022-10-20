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
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/domain/error.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockFavoritesRepository extends Mock implements FavoritePostRepository {}

class MockPostVoteRepository extends Mock implements PostVoteRepository {}

class MockBlacklistedTagsRepository extends Mock
    implements BlacklistedTagsRepository {}

void main() {
  final mockPostRepo = MockPostRepository();
  final mockAccountRepo = MockAccountRepository();
  final mockBlacklistedRepo = MockBlacklistedTagsRepository();
  final mockFavRepo = MockFavoritesRepository();
  final mockPostVoteRepo = MockPostVoteRepository();
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
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.tag_limit',
        )
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
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.database_timeout',
        )
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
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.unknown',
        )
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

        when(() => mockFavRepo.getFavorites(any(), any())).thenThrow(Error());
      },
      tearDown: () {
        reset(mockPostRepo);
        reset(mockFavRepo);
      },
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.unknown',
        )
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
      ),
      act: (bloc) =>
          bloc.add(const PostFetched(tags: '', fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial().copyWith(status: LoadStatus.loading),
        PostState.initial().copyWith(
          status: LoadStatus.failure,
          exceptionMessage: 'search.errors.unknown',
        )
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
      },
      tearDown: () {
        reset(mockPostRepo);
        reset(mockAccountRepo);
        reset(mockBlacklistedRepo);
        reset(mockFavRepo);
      },
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostRefreshed(fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial(),
        PostState.initial().copyWith(
          status: LoadStatus.success,
          posts: [
            PostData(post: Post.empty(), isFavorited: false),
            PostData(post: Post.empty(), isFavorited: false),
          ],
        )
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
      },
      seed: () => PostState.initial().copyWith(
        page: 1,
        posts: [
          PostData(post: Post.empty(), isFavorited: false),
          PostData(post: Post.empty(), isFavorited: false),
        ],
      ),
      tearDown: () {
        reset(mockPostRepo);
        reset(mockAccountRepo);
        reset(mockBlacklistedRepo);
        reset(mockFavRepo);
      },
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
      ),
      act: (bloc) =>
          bloc.add(const PostFetched(tags: '', fetcher: LatestPostFetcher())),
      expect: () => [
        PostState.initial().copyWith(
          status: LoadStatus.loading,
          posts: [
            PostData(post: Post.empty(), isFavorited: false),
            PostData(post: Post.empty(), isFavorited: false),
          ],
        ),
        PostState.initial().copyWith(
          page: 2,
          status: LoadStatus.success,
          posts: [
            PostData(post: Post.empty(), isFavorited: false),
            PostData(post: Post.empty(), isFavorited: false),
            PostData(post: Post.empty(), isFavorited: false),
          ],
        )
      ],
    );
  });

  group('[post bloc item update]', () {
    blocTest<PostBloc, PostState>(
      '3 posts initial, update the middle post',
      seed: () => PostState.initial().copyWith(
        page: 1,
        posts: [
          PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
          PostData(post: Post.empty().copyWith(id: 2), isFavorited: false),
          PostData(post: Post.empty().copyWith(id: 3), isFavorited: false),
        ],
      ),
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        stateIdGenerator: () => 123,
      ),
      act: (bloc) => bloc.add(PostUpdated(
          post: Post.empty().copyWith(
        id: 2,
        tags: ['foo'],
      ))),
      expect: () => [
        PostState.initial().copyWith(
          id: 123,
          posts: [
            PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
            PostData(
              post: Post.empty().copyWith(id: 2, tags: ['foo']),
              isFavorited: false,
            ),
            PostData(post: Post.empty().copyWith(id: 3), isFavorited: false),
          ],
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      '3 posts initial, update the non-exist post',
      seed: () => PostState.initial().copyWith(
        page: 1,
        posts: [
          PostData(post: Post.empty().copyWith(id: 1), isFavorited: false),
          PostData(post: Post.empty().copyWith(id: 2), isFavorited: false),
          PostData(post: Post.empty().copyWith(id: 3), isFavorited: false),
        ],
      ),
      build: () => PostBloc(
        postRepository: mockPostRepo,
        accountRepository: mockAccountRepo,
        favoritePostRepository: mockFavRepo,
        blacklistedTagsRepository: mockBlacklistedRepo,
        postVoteRepository: mockPostVoteRepo,
        stateIdGenerator: () => 123,
      ),
      act: (bloc) => bloc.add(PostUpdated(
          post: Post.empty().copyWith(
        id: 4,
        tags: ['foo'],
      ))),
      expect: () => [],
    );
  });
}
