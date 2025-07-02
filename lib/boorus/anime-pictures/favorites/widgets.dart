// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/scaffolds/scaffolds.dart';
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
        final posts = await ref
            .read(animePicturesClientProvider(config))
            .getPosts(starsBy: uid, page: page)
            .then((values) => values.map(dtoToAnimePicturesPost).toList());

        return posts.toResult();
      }),
    );
  }
}
