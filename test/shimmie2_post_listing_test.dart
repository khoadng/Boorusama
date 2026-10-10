// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/boorus/shimmie2/clients/providers.dart';
import 'package:boorusama/boorus/shimmie2/favorites/providers.dart';
import 'package:boorusama/boorus/shimmie2/posts/providers.dart';
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/posts/favorites/providers.dart';
import 'package:boorusama/core/posts/favorites/src/data/providers.dart';
import 'package:boorusama/core/posts/favorites/types.dart';
import 'package:boorusama/core/posts/post/types.dart';

void main() {
  final config = BooruConfig.empty.copyWith(url: 'https://example.com/');
  final auth = config.auth;

  final cases = [
    (
      name: 'favorite status loads',
      canFavorite: () => Future.value(true),
      filter: (List<int> ids) => Future.value(ids),
    ),
    (
      name: 'the favorite lookup fails',
      canFavorite: () => Future.value(true),
      filter: (List<int> _) =>
          Future<List<int>>.error(Exception('lookup failed')),
    ),
    (
      name: 'the favorite support check fails',
      canFavorite: () => Future<bool>.error(Exception('extensions failed')),
      filter: (List<int> ids) => Future.value(ids),
    ),
  ];

  for (final c in cases) {
    test('listing still returns posts when ${c.name}', () async {
      final container = ProviderContainer(
        overrides: [
          shimmie2ClientProvider(auth).overrideWithValue(_FakeShimmie2Client()),
          useGraphQLClientProvider(auth)
              .overrideWith((ref) => Future.value(false)),
          shimmie2CanFavoriteProvider(auth).overrideWith(
            (ref) => c.canFavorite(),
          ),
          favoriteRepoProvider(auth).overrideWithValue(
            FavoriteRepositoryBuilder<Post>(
              add: (_) async => AddFavoriteStatus.success,
              remove: (_) async => true,
              isFavorited: (_) => false,
              canFavorite: () => true,
              filter: c.filter,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(shimmie2PostRepoProvider(config.search));
      final result = await repo.getPosts('', 1, limit: 20).run();

      expect(
        result.map((r) => r.posts.map((p) => p.id).toList()).toNullable(),
        [1, 2],
      );
    });
  }
}

class _FakeShimmie2Client extends Shimmie2Client {
  _FakeShimmie2Client() : super(baseUrl: 'https://example.com/');

  @override
  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
    bool useGraphQL = false,
  }) async => [
    PostDto(id: 1, fileUrl: 'https://example.com/1.jpg', ext: 'jpg'),
    PostDto(id: 2, fileUrl: 'https://example.com/2.jpg', ext: 'jpg'),
  ];
}
