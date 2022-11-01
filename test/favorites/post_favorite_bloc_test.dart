// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class MockFavoritesRepository extends Mock implements FavoritePostRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  final favRepo = MockFavoritesRepository();
  final userRepo = MockUserRepository();

  blocTest<PostFavoriteBloc, PostFavoriteState>(
    'refresh 2 favorites',
    setUp: () {
      when(() => favRepo.getFavorites(any(), any()))
          .thenAnswer((invocation) async => [
                Favorite.empty().copyWith(id: 1, userId: 1),
                Favorite.empty().copyWith(id: 2, userId: 2),
              ]);

      when(() => userRepo.getUsersByIdStringComma(any()))
          .thenAnswer((invocation) async => [
                User.placeholder().copyWith(id: 1),
                User.placeholder().copyWith(id: 2),
              ]);
    },
    tearDown: () {
      reset(favRepo);
      reset(userRepo);
    },
    build: () => PostFavoriteBloc(
      favoritePostRepository: favRepo,
      userRepository: userRepo,
    ),
    act: (bloc) =>
        bloc.add(const PostFavoriteFetched(postId: 1, refresh: true)),
    expect: () => [
      PostFavoriteState.initial().copyWith(refreshing: true),
      PostFavoriteState.initial().copyWith(
        refreshing: false,
        favoriters: [
          User.placeholder().copyWith(id: 1),
          User.placeholder().copyWith(id: 2),
        ],
      ),
    ],
  );

  blocTest<PostFavoriteBloc, PostFavoriteState>(
    'refresh a post with no favorites',
    setUp: () {
      when(() => favRepo.getFavorites(any(), any()))
          .thenAnswer((invocation) async => []);

      when(() => userRepo.getUsersByIdStringComma(any()))
          .thenAnswer((invocation) async => []);
    },
    tearDown: () {
      reset(favRepo);
      reset(userRepo);
    },
    build: () => PostFavoriteBloc(
      favoritePostRepository: favRepo,
      userRepository: userRepo,
    ),
    act: (bloc) =>
        bloc.add(const PostFavoriteFetched(postId: 1, refresh: true)),
    expect: () => [
      PostFavoriteState.initial().copyWith(refreshing: true),
      PostFavoriteState.initial().copyWith(
        refreshing: false,
        favoriters: [],
      ),
    ],
  );

  blocTest<PostFavoriteBloc, PostFavoriteState>(
    'have 2 favorites then fetch 2 more favorites',
    setUp: () {
      when(() => favRepo.getFavorites(any(), any()))
          .thenAnswer((invocation) async => [
                Favorite.empty().copyWith(id: 3, userId: 3),
                Favorite.empty().copyWith(id: 4, userId: 4),
              ]);

      when(() => userRepo.getUsersByIdStringComma(any()))
          .thenAnswer((invocation) async => [
                User.placeholder().copyWith(id: 3),
                User.placeholder().copyWith(id: 4),
              ]);
    },
    tearDown: () {
      reset(favRepo);
      reset(userRepo);
    },
    build: () => PostFavoriteBloc(
      favoritePostRepository: favRepo,
      userRepository: userRepo,
      initialData: [
        User.placeholder().copyWith(id: 1),
        User.placeholder().copyWith(id: 2),
      ],
    ),
    act: (bloc) => bloc.add(const PostFavoriteFetched(postId: 1)),
    expect: () => [
      PostFavoriteState.initial().copyWith(
        loading: true,
        favoriters: [
          User.placeholder().copyWith(id: 1),
          User.placeholder().copyWith(id: 2),
        ],
      ),
      PostFavoriteState.initial().copyWith(
        page: 2,
        loading: false,
        favoriters: [
          User.placeholder().copyWith(id: 1),
          User.placeholder().copyWith(id: 2),
          User.placeholder().copyWith(id: 3),
          User.placeholder().copyWith(id: 4),
        ],
      ),
    ],
  );
}
