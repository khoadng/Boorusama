// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/widgets.dart';
import '../../../core/posts/post/types.dart';
import '../client_provider.dart';
import '../configs/extra_data.dart';
import '../posts/parser.dart' as parser;

class EshuushuuFavoritesPage extends ConsumerWidget {
  const EshuushuuFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final extraData = EshuushuuExtraData.fromPassHash(config.passHash);

    return BooruConfigAuthFailsafe(
      builder: (_) => _EshuushuuFavoritesPageInternal(
        userId: extraData.userId ?? 0,
      ),
    );
  }
}

class _EshuushuuFavoritesPageInternal extends ConsumerWidget {
  const _EshuushuuFavoritesPageInternal({
    required this.userId,
  });

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final client = ref.watch(eshuushuuClientProvider(config));

    return FavoritesPageScaffold(
      favQueryBuilder: null,
      fetcher: (page) => TaskEither.Do(($) async {
        final dtos = await client.getPosts(
          favoritedByUserId: userId,
          page: page,
        );

        final posts = dtos
            .map((dto) => parser.postDtoToPost(dto, null))
            .toList();

        notifier.preloadInternal(
          posts,
          selfFavorited: (post) => true,
        );

        return posts.toResult();
      }),
    );
  }
}
