// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/favorites/widgets.dart';
import '../../../core/posts/post/types.dart';
import '../client_provider.dart';
import '../posts/parser.dart';
import '../users/providers.dart';

class AnimePicturesFavoritesPage extends ConsumerWidget {
  const AnimePicturesFavoritesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider);
    final config = ref.watchConfigAuth;

    return FavoritesPageScaffold(
      favQueryBuilder: null,
      fetcher: (page) => TaskEither.Do(($) async {
        final result = await ref
            .read(animePicturesClientProvider(config))
            .getPostsWithTotal(starsBy: uid, page: page);
        final posts = result.posts.map(dtoToAnimePicturesPost).toList();

        return posts.toResult(
          total: result.postsCount,
          maxPage: result.appMaxPage,
        );
      }),
    );
  }
}
